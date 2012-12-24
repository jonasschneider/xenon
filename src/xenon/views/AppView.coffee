Backbone = require 'backbone'
GameView = require './GameView'
Game = require 'xenon/GameOnClient'
io       = require 'socket.io'

module.exports = class AppView extends Backbone.View
  initialize: ->
    @gameDisplay = new GameView({model: @model.game, appView: this})
    
    @gameDisplay.bind 'ready', =>
      console.log("connecting..")
      console.warn "faking latency"
      fakeLagDown = 90
      fakeLagUp = 130
      socket = io.connect('http://'+location.hostname)
      
      socket.on 'update', (e) =>
        
        setTimeout =>
          @model.trigger 'update', e
        , fakeLagDown
      
      socket.on 'log', (e) ->
        console.log e
      
      socket.on 'ping', (timestamp) =>
        socket.emit 'pong', timestamp

      socket.on 'applySnapshotAndRun', (snapshot, ticks) =>
        console.log snapshot
        @model.game.world.applyFullSnapshot(snapshot)
        @model.game.lastAppliedUpdateTicks = ticks
        @model.game.ticks = ticks
        
        # delay for one tick in order to, well, compensate for the server being faster?
        setTimeout =>
          @model.game.run()
        , Game.tickLength
      
      socket.on 'setLocalPlayerId',  (player) =>
        @localPlayerId = player
        @trigger 'change:localPlayerId', player
        
        console.log 'localPlayerId set: ' + player
      
      socket.on 'connect', =>
        console.log 'connected to server'
        
        @model.bind 'publish', (e) =>
          setTimeout =>
            socket.emit('update', e)
          , fakeLagUp