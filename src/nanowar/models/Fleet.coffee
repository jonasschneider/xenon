define (require) ->
  Player = require('./Player')
  Entity = require('./Entity')
  Cell = require('./Entity')
  
  _      = require('underscore')
  util = require('../helpers/util')

  # attributes: Cell from, Cell to, Game game, Player owner, int strength, int launchedAt
  return class Fleet extends Entity
    defaults:
      launched_at: null
      speedPerTick: 6

    relationSpecs:
      from:
        relatedModel: Cell
        directory: 'game.entities'
      to:
        relatedModel: Cell
        directory: 'game.entities'
      owner:
        relatedModel: Player
        directory: 'game.entities'

    initialize: ->
      if @game.get('onServer')
        @game.bind 'tick', @update, this
        
        @bind 'remove', =>
          @game.unbind 'tick', @update, this
    
    startPosition: ->
      util.nearestBorder @get('from').position(), @get('from').get('size'), @get('to').position()
    
    endPosition: ->
      util.nearestBorder @get('to').position(), @get('to').get('size'), @get('from').position()
    
    eta: ->
      @arrivalTime() - @game.ticks
    
    flightTime: ->
      Math.round @distance() / @get('speedPerTick')
    
    arrivalTime: ->
      @get('launched_at') + @flightTime()
    
    distance: ->
      util.distance(@startPosition(), @endPosition())
      
    canLaunch: ->
      @get('from') && @get('to') && @get('from') != @get('to') && @get('strength') > 0
    
    launch: ->
      @set owner: @get('from').get('owner')

      if !@get('strength')
        @set strength: Math.floor(@get('from').getCurrentStrength() / 2)

      if @canLaunch()
        console.log "[Tick#{@game.ticks}] [Fleet #{@cid}] Fleet of #{@get('strength')} launching #{@get('from').cid}->#{@get('to').cid}; arrival in #{@flightTime()} ticks"
        @get('from').changeCurrentStrengthBy -@get('strength')
        @set launched_at: @game.ticks
        true
      else false
    
    arrived: ->
      @arrivalTime() < @game.ticks
    
    update: ->
      if @arrived()
        console.log "[Tick#{@game.ticks}] [Fleet #{@cid}] Arrived from route #{@get('from').cid}->#{@get('to').cid}"
        @get('to').handle_incoming_fleet this
        @collection.remove this