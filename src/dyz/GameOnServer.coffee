_                 = require 'underscore'
ScheduledGame          = require './helpers/ScheduledGame'

module.exports = class extends ScheduledGame
  publishRun: true

  constructor: ->
    super
    @tellQueue = []

    @bind 'update', (e) =>
      console.info "game got update ", JSON.stringify(e)

      if e.commands # for one-off commands
        @tellQueue.push(to: '$self', what: cmd[0], with: cmd[1]) for cmd in e.commands

  tellSelf: (what, args...) ->
    tell = to: '$self', what: what, with: args
    @tellQueue.push tell

  addPlayer: (player) ->
    console.warn "new player", player

  runTell: (tell) ->
    console.log("running:", tell)
    throw 'invalid target' if tell.to != '$self' # TODO
    this[tell.what].call(this, tell.with...)

  runTells: (tells) ->
    @runTell(tell) for tell in tells

  runTellQueue: ->
    @runTells(@tellQueue)
    @tellQueue = []
    
  tickAction: ->
    console.info "=== SERVER TICKING #{@ticks}"
    startTime = new Date().getTime()

    entityMutation = @world.mutate =>
      @runTellQueue()
      @world.each (ent) =>
        ent.update && ent.update()
        @world.remove(ent) if ent.get('dead')

    expectedPassedTicks = (new Date().getTime() - @tickZeroTime) / 1000 * ScheduledGame.ticksPerSecond
    syncError = (@ticks - expectedPassedTicks).toFixed(1)

    endTime = new Date().getTime()

    @trigger 'publish', 
      tick: @ticks
      entityMutation: entityMutation
      serverProcessingTime: (endTime-startTime)
      syncError: syncError

    console.info "=== SERVER TICKED TO #{@ticks}"
