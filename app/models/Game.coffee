#= require <nanowar>
#= require "Cells"
#= require "Cell"
#= require "Fleets"
#= require "Players"
#= require <commands/SendFleetCommand>

if exports?
  onServer = true
  Backbone = require('../vendor/backbone')
  
  root = exports
  Nanowar = {}
  Nanowar.Cell    = require('./Cell').Cell
  Nanowar.Player = require('./Player').Player
  Nanowar.Fleet  = require('./Fleet').Fleet
  Nanowar.SendFleetCommand  = require('../commands/SendFleetCommand').SendFleetCommand
  Nanowar.EntityCollection = require('./EntityCollection').EntityCollection
  _               = require 'underscore'
else
  Backbone  = window.Backbone
  Nanowar   = window.Nanowar
  root = Nanowar

class root.Game extends Backbone.Model
  defaults:
    tickLength: 1000 / 10
  
  initialize: ->
    @entities = new Nanowar.EntityCollection [], game: this, types: [Nanowar.Cell, Nanowar.Player]

    if onServer?
      @entities.bind 'publish', (e) =>
        @trigger 'publish',
          entities: e
          ticks: @ticks
      
      @bind 'start', =>
        @trigger 'publish', 'start'

    @bind 'update', (e) =>
      if e.ticks?
        @ticks = e.ticks
      
      @entities.trigger 'update', e.entities if e.entities?
      
      if e.sendFleetCommand?
        e.sendFleetCommand.game = this
        cmd = new Nanowar.SendFleetCommand e.sendFleetCommand
        cmd.run()
        #@trigger 'publish', {sendFleet: e.sendFleet} if onServer?
      
      @run() if e == 'start'
    
    

    @ticks = 0
    @running = false
    @stopping = false
  
  getCells: ->
    @entities.select (entity) -> 
      entity instanceof Nanowar.Cell

  check_for_end: ->
    owners = []
    _(@getCells()).each (cell) ->
      cellOwner = cell.get 'owner'
      owners.push cellOwner if cellOwner? && owners.indexOf(cellOwner) == -1
    
    if owners.length == 1
      console.log "Game over"
      @halt()
      @trigger 'end', winner: owners[0]
  
  run: ->
    console.log "GOGOGOG"
    
    @trigger 'start'
    
    @schedule()
    
  schedule: ->
    setTimeout =>
      @tick()
    , @get 'tickLength'
  
  halt: ->
    @stopping = true
  
  tick: ->
    @schedule() unless @stopping
    @ticks++
    @trigger 'tick'
    @check_for_end()
  
  ticksToTime: (ticks) ->
    ticks * @get 'tickLength'