World  = require('dyz/World')
Backbone          = require 'backbone'
_                 = require 'underscore'

module.exports = class GameCommon
  entityTypes: {}
  log: (stuff...) ->
    console.info stuff...

  constructor: ->
    @ticks = 0
    @running = false
    @world = new World @entityTypes
  
  halt: ->
    console.log 'HALTING'
    @trigger 'halt'
    @running = false
  
  tick: ->
    @ticks++
    @world.ticks = @ticks
    @world.tickStartedAt = new Date().getTime()
    @world.tickLength = GameCommon.tickLength

    # Pass the return value on
    @tickAction()

  ticksToTime: (ticks) ->
    ticks * GameCommon.tickLength

  run: ->
    console.log "GOGOGOG"
    @trigger 'run'
    @tickZeroTime = new Date().getTime() - (@ticks * GameCommon.tickLength)
    if @publishRun
      setTimeout =>
        @trigger 'publish', run: true
      , 30

    @running = true
    @scheduleTick()
  
  scheduleTick: ->
    val = @tick()
    
    if @running
      realtimeForNextTick = @tickZeroTime + (@ticks * GameCommon.tickLength)
      timeout = realtimeForNextTick - new Date().getTime()

      #if val < 0 # see tickClient()
      #  @log "skewing clock to get rid of lag"
      #  timeout += 10

      if timeout < 0
        console.warn "WARNING: desynched, scheduling next tick immediately"
        timeout = 0
      
      setTimeout =>
        @scheduleTick()
      , timeout

_.extend(GameCommon.prototype, Backbone.Events)

GameCommon.tickLength = 1000 / 20
GameCommon.ticksPerSecond = 1000 / GameCommon.tickLength