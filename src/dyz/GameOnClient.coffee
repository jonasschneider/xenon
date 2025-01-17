_                 = require 'underscore'
GameCommon          = require './helpers/GameCommon'
WorldStateMutation = require './helpers/WorldStateMutation'

module.exports = class GameOnClient extends GameCommon
  constructor: (options) ->
    super
    @options = options
    
    @serverUpdates = {}

    @bind 'update', (e, sizeOnWire, sizeUncompressed) =>
      @log "client got update ", e

      @dataOnWireReceivedSinceTick += sizeOnWire if sizeOnWire
      @dataUncompressedReceivedSinceTick += sizeUncompressed if sizeUncompressed
      
      if e.entityMutation
        e.entityMutation = WorldStateMutation.parse(e.entityMutation)
        @serverUpdates[e.tick] = e
        @lastReceivedUpdateTicks = e.tick # websockets have guaranteed order
      else
        console.warn "update without entityMutation", e

    @clientLag = 0
    @clientLagTotal = 0
    @lastReceivedUpdateTicks = -1
    @lastAppliedUpdateTicks = 0
    @dataOnWireReceivedSinceTick = 0
    @dataUncompressedReceivedSinceTick = 0

    @commandQueue = []
  
  queueClientCommand: (cmd, args...) ->
    @commandQueue.push [cmd, args]

  sendClientInput: ->
    if @commandQueue.length > 0
      @trigger 'publish', ticks: @ticks, commands: @commandQueue
      @commandQueue = []

  # Returns a negative value if the client is lagging behind
  tickAction: ->
    @log "=== CLIENT TICKING #{@ticks}"
    startTime = new Date().getTime()

    @sendClientInput()

    if @dirtyWorldResetSnapshot
      @world.applyAttributeSnapshot(@dirtyWorldResetSnapshot)
      delete @dirtyWorldResetSnapshot

    reachableTicks = Math.min(@ticks, @lastReceivedUpdateTicks)

    while reachableTicks > @lastAppliedUpdateTicks
      next = ++@lastAppliedUpdateTicks

      lastAppliedUpdate = @serverUpdates[next]
      if lastAppliedUpdate
        @trigger 'instrument:mutation', lastAppliedUpdate.entityMutation if @ticks % 101 == 0
        @world.applyMutationWithInterpolationCheckpoint(lastAppliedUpdate.entityMutation)
      else
        console.error 'tried to apply mutation, but did not have dataz'
        console.error lastAppliedUpdate, next, @serverUpdates
        throw 'wtf'

      if next-2 > 0
        delete @serverUpdates[next-2] # keep the mutation that led to the recent tick and the one before that

    if reachableTicks < @ticks && reachableTicks > -1 # allow catching up
      ticksToExtrapolate = @ticks - reachableTicks
      startingPoint = reachableTicks
      @log "client is lagging behind, going to extrapolate for #{ticksToExtrapolate} ticks from tick #{startingPoint}"

      if ticksToExtrapolate > 10 # todo: constant
        console.log "lost more than 10 ticks, connection lost :("
        @halt()
        return

      if @lastAppliedUpdateTicks > 2 && @serverUpdates[startingPoint] && @serverUpdates[startingPoint-1]
        @dirtyWorldResetSnapshot = @world.snapshotAttributes()
        # these are the mutations that led to the two last good ticks
        mut1 = @serverUpdates[startingPoint-1].entityMutation
        mut2 = @serverUpdates[startingPoint].entityMutation

        @world.state.extrapolate(mut1, mut2, ticksToExtrapolate)
      else
        console.log 'not enough data for extrapolate'

    endTime = new Date().getTime()


    @trigger 'instrument:client-tick', 
      totalUpdateSize: @dataOnWireReceivedSinceTick
      uncompressedUpdateSize: @dataUncompressedReceivedSinceTick
      clientProcessingTime: (endTime-startTime)
      serverProcessingTime: (lastAppliedUpdate || {serverProcessingTime: 0}).serverProcessingTime
      lastServerTotalTime: (lastAppliedUpdate || {lastTotalTime: 0}).lastTotalTime
    @dataOnWireReceivedSinceTick = @dataUncompressedReceivedSinceTick = 0

    reachableTicks - @ticks
  