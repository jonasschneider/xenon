_                 = require 'underscore'
GameCommon          = require './helpers/GameCommon'

module.exports = class extends GameCommon
  publishRun: true

  constructor: ->
    super
    @tellQueue = []
    @playerInput = {}

    @loadMap() if @loadMap

    @bind 'update', (e) =>
      @log "game got update ", JSON.stringify(e)

      if e.player
        if e.commands # for one-off commands
          @tellQueue.push(to: '$self', what: cmd[0], with: cmd[1]) for cmd in e.commands

        if e.inputState
          # TODO: record history
          @log "received client input from #{e.player} for tick #{e.ticks} at server tick #{@ticks}"
          @playerInput[e.player] = e.inputState
  
  tellSelf: (what, args...) ->
    tell = to: '$self', what: what, with: args
    @tellQueue.push tell

  addPlayer: (player) ->
    console.warn "new player", player

  runTell: (tell) ->
    @log("running:", tell)
    throw 'invalid target' if tell.to != '$self' # TODO
    this[tell.what].call(this, tell.with...)

  runTells: (tells) ->
    @runTell(tell) for tell in tells

  runTellQueue: ->
    @runTells(@tellQueue)
    @tellQueue = []
    
  tickAction: ->
    @log "=== SERVER TICKING #{@ticks}"
    startTime = new Date().getTime()

    entityMutation = @world.mutate =>
      @runTellQueue()
      @world.each (ent) =>
        ent.update && ent.update(@playerInput)
        @world.remove(ent) if ent.get('dead')

    expectedPassedTicks = (new Date().getTime() - @tickZeroTime) / 1000 * GameCommon.ticksPerSecond
    syncError = (@ticks - expectedPassedTicks).toFixed(1)

    endTime = new Date().getTime()

    @trigger 'publish', 
      tick: @ticks
      entityMutation: entityMutation
      serverProcessingTime: (endTime-startTime)
      lastTotalTime: @lastTickTotalTime || 0
      syncError: syncError

    @lastTickTotalTime = new Date().getTime() - startTime
    @log "=== SERVER TICKED TO #{@ticks}"
