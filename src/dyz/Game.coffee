Ship              = require('xenon/entities/Ship')
World  = require('dyz/World')
_                 = require 'underscore'
Backbone          = require 'backbone'

module.exports = class Game extends Backbone.Model
  entityTypes:
    Ship: Ship
  
  initialize: ->
    @world = new World @entityTypes

    @serverUpdates = {}

    @bind 'update', (e) =>
      console.info "game got update ", JSON.stringify(e)

      if e.tells
        @tellQueue.push(tell) for tell in e.tells

      if e.entityMutation
        @dataReceivedSinceTick += JSON.stringify(e).length
        @serverUpdates[e.tick] = e
        @lastReceivedUpdateTicks = e.tick # websockets have guaranteed order

      @run() if e.run
    
    @ticks = 0

    # client vars
    @clientLag = 0
    @clientLagTotal = 0
    @lastReceivedUpdateTicks = -1
    @lastAppliedUpdateTicks = 0
    @dataReceivedSinceTick

    # common vars
    @running = false
    @tellQueue = []
    @sendQueue = []
  
  tellSelf: (what, args...) ->
    tell = to: '$self', what: what, with: args
    if @get('onServer')
      @tellQueue.push tell
    else
      @sendQueue.push tell

  addPlayer: (player) ->
    console.warn "new player", player


  runTell: (tell) ->
    console.log("running:", tell)
    #if tell.to == '$self' # TODO: ONLY WORKS FOR TELLS TO GAME AT THIS TIME!
    this[tell.what].call(this, tell.with...)

  runTells: (tells) ->
    @runTell(tell) for tell in tells

  sendClientTells: ->
    if @sendQueue.length > 0
      @trigger 'publish', tells: @sendQueue
      @sendQueue = []

  runTellQueue: ->
    @runTells(@tellQueue)
    @tellQueue = []
    
  halt: ->
    console.log 'HALTING'
    @running = false
  
  # Returns a negative value if the client is lagging behind
  tickClient: ->
    console.info "=== CLIENT TICKING #{@ticks}"
    startTime = new Date().getTime()

    @sendClientTells()

    if @dirtyWorldResetSnapshot
      @world.applyAttributeSnapshot(@dirtyWorldResetSnapshot)
      delete @dirtyWorldResetSnapshot

    reachableTicks = Math.min(@ticks, @lastReceivedUpdateTicks)

    while reachableTicks > @lastAppliedUpdateTicks
      next = ++@lastAppliedUpdateTicks

      lastAppliedUpdate = @serverUpdates[next]
      if lastAppliedUpdate
        @world.applyMutation(lastAppliedUpdate.entityMutation)
      else
        console.error 'tried to apply mutation, but did not have dataz'
        console.error lastAppliedUpdate, next, @serverUpdates
        throw 'wtf'

      if next-2 > 0
        delete @serverUpdates[next-2] # keep the mutation that led to the recent tick and the one before that


    if reachableTicks < @ticks && reachableTicks > -1 # allow catching up
      ticksToExtrapolate = @ticks - reachableTicks
      startingPoint = reachableTicks
      console.log "client is lagging behind, going to extrapolate for #{ticksToExtrapolate} ticks from tick #{startingPoint}"

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
      totalUpdateSize: @dataReceivedSinceTick
      clientProcessingTime: (endTime-startTime)
      serverProcessingTime: (lastAppliedUpdate || {serverProcessingTime: 0}).serverProcessingTime
    @dataReceivedSinceTick = 0

    reachableTicks - @ticks
  
  tickServer: ->
    console.info "=== SERVER TICKING #{@ticks}"
    startTime = new Date().getTime()

    entityMutation = @world.mutate =>
      @runTellQueue()
      @world.each (ent) =>
        ent.update && ent.update()
        @world.remove(ent) if ent.get('dead')

    expectedPassedTicks = (new Date().getTime() - @tickZeroTime) / 1000 * Game.ticksPerSecond
    syncError = (@ticks - expectedPassedTicks).toFixed(1)

    endTime = new Date().getTime()

    @trigger 'publish', 
      tick: @ticks
      entityMutation: entityMutation
      serverProcessingTime: (endTime-startTime)
      syncError: syncError

    console.info "=== SERVER TICKED TO #{@ticks}"

  tick: ->
    @ticks++
    @world.ticks = @ticks
    @world.tickStartedAt = new Date().getTime()
    @world.tickLength = Game.tickLength

    # Pass the return value on
    if @get('onServer')
      @tickServer()
    else
      @tickClient()

  ticksToTime: (ticks) ->
    ticks * Game.tickLength


  # TIME-CRITICAL STUFF
  run: -> # probably blows up synchronisation
    console.log "GOGOGOG"
    @trigger 'run'
    @tickZeroTime = new Date().getTime() - (@ticks * Game.tickLength)
    if @get('onServer')
      setTimeout =>
        @trigger 'publish', run: true
      , 30

    @running = true
    @scheduleTick()
  
  scheduleTick: ->
    val = @tick()
    
    if @running
      realtimeForNextTick = @tickZeroTime + (@ticks * Game.tickLength)
      timeout = realtimeForNextTick - new Date().getTime()

      if val < 0 # see tickClient()
        console.log "skewing clock to get rid of lag"
        timeout += 10

      if timeout < 0
        console.warn "WARNING: desynched, scheduling next tick immediately"
        timeout = 0
      
      setTimeout =>
        @scheduleTick()
      , timeout


Game.tickLength = 1000 / 10
Game.ticksPerSecond = 1000 / Game.tickLength