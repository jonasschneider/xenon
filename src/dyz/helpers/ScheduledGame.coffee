World  = require('dyz/World')
Backbone          = require 'backbone'
_                 = require 'underscore'

module.exports = class ScheduledGame
  entityTypes: {}

  constructor: ->
    @ticks = 0
    @running = false
    @world = new World @entityTypes
  
  halt: ->
    console.log 'HALTING'
    @running = false
  
  tick: ->
    @ticks++
    @world.ticks = @ticks
    @world.tickStartedAt = new Date().getTime()
    @world.tickLength = ScheduledGame.tickLength

    # Pass the return value on
    @tickAction()

  ticksToTime: (ticks) ->
    ticks * ScheduledGame.tickLength

  run: ->
    console.log "GOGOGOG"
    @trigger 'run'
    @tickZeroTime = new Date().getTime() - (@ticks * ScheduledGame.tickLength)
    if @publishRun
      setTimeout =>
        @trigger 'publish', run: true
      , 30

    @running = true
    @scheduleTick()
  
  scheduleTick: ->
    val = @tick()
    
    if @running
      realtimeForNextTick = @tickZeroTime + (@ticks * ScheduledGame.tickLength)
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

_.extend(ScheduledGame.prototype, Backbone.Events)

ScheduledGame.tickLength = 1000 / 10
ScheduledGame.ticksPerSecond = 1000 / ScheduledGame.tickLength