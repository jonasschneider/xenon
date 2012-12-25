io       = require 'socket.io'

module.exports = class SocketIOClient
  constructor: (Game) ->
    @game = new Game

  connect: ->
    console.log("connecting..")
    console.warn "faking latency"
    fakeLagDown = 90
    fakeLagUp = 130
    #fakeLagDown = fakeLagUp = 0
    socket = io.connect('http://'+location.hostname)
    
    socket.on 'update', (e) =>
      setTimeout =>
        @game.trigger 'update', e
      , fakeLagDown
    
    socket.on 'log', (e) ->
      console.log e
    
    socket.on 'ping', (timestamp) =>
      socket.emit 'pong', timestamp

    socket.on 'applySnapshotAndRun', (snapshot, ticks) =>
      console.log 'applySnapshotAndRun', ticks, snapshot
      
      @game.world.applyFullSnapshot(snapshot)
      @game.lastAppliedUpdateTicks = ticks
      @game.ticks = ticks
      
      @game.run()
    
    socket.on 'setLocalPlayerId',  (player) =>
      @localPlayerId = player
      
      console.log 'localPlayerId set: ' + player
    
    socket.on 'connect', =>
      console.log 'connected to server'
      
      @game.bind 'publish', (e) =>
        setTimeout =>
          socket.emit('update', e)
        , fakeLagUp