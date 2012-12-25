World  = require('dyz/World')
Backbone          = require 'backbone'
_                 = require 'underscore'

module.exports = class GameCommon
  entityTypes: {}
  log: (stuff...) ->
    #console.info stuff...

  constructor: ->
    @ticks = 0
    @running = false
    @world = new World @entityTypes
    @clockSkew = 0
  
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
    
    if val < 0 # see tickClient()
      # we are behind
      @log "skewing clock to get rid of lag"
      @clockSkew += 10
    else if val > 0 && @clockSkew > 0
      @log "reducing clock skew"
      @clockSkew -= 10

    if @running
      realtimeForNextTick = @tickZeroTime + @clockSkew + (@ticks * GameCommon.tickLength)
      timeout = realtimeForNextTick - new Date().getTime()

      if timeout < 0
        if @abortOnDesync
          throw "desynced! next tick should be in #{timeout}ms.."
        else
          console.warn "WARNING: desynched, scheduling next tick immediately"
          timeout = 0
      
      setTimeout =>
        @scheduleTick()
      , timeout

_.extend(GameCommon.prototype, Backbone.Events)

GameCommon.tickLength = 1000 / 20
GameCommon.ticksPerSecond = 1000 / GameCommon.tickLength