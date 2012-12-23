App     = require('./Peer')
util    = require 'util'
_       = require 'underscore'
Backbone= require 'backbone'

class NetworkedPlayer
  constructor: (socket, ship) ->
    @socket = socket
    @ship = ship
    
    @socket.emit 'log', 'You are: ' + @toString()
    
    pingSentAt = null
    @socket.on 'pong', (pingSentAt) => 
      @latency = new Date().getTime() - pingSentAt
      @socket.emit 'log', "Your RTT is #{@latency}"
    pingSentAt = new Date().getTime()
    @socket.emit 'ping', pingSentAt
    
    @socket.on 'update', (e) =>
      @trigger 'update', e
  
  send: ->
    clean = []
    _(arguments).each (arg) ->
      clean.push arg
    
    @socket.emit.apply(@socket, clean)
  updateLocalPlayerId: ->
    @socket.emit 'setLocalPlayerId', @playerent.id

_.extend(NetworkedPlayer.prototype, Backbone.Events)

class Match
  constructor: ->
    @players = []
    
    @app = new App onServer: true
    @game = @app.game

    @app.bind 'publish', @distributeUpdate, this

    @sendToAll 'log', 'starting soon!'
    
    
    console.log 'starting. players:'
    _(@players).each (player) =>
      console.log "- #{player} (socket id #{player.socket.id})"
    
    @game.world.enableStrictMode()

    setTimeout =>
      @game.run()
    , 500
  
  addPlayer: (clientSocket) ->
    console.log clientSocket.id + " connected"
    @game.tellSelf('addShip', name: ("Player " + (@players.length + 1)))
    console.log "made player ship"
    player = new NetworkedPlayer clientSocket, null
    
    player.bind 'update', (e) =>
      #player.socket.broadcast.emit 'update', e # security?
      @app.trigger 'update', e
    
    snapshot = @game.world.snapshotFull()
    player.send 'applySnapshot', snapshot
  
  distributeUpdate: (update) ->
    @sendToAll('update', update)
  
  sendToAll: ->
    clean = []
    _(arguments).each (arg) ->
      clean.push arg
      
    _(@players).each (player) -> # potential problem since we don't use @game.players
      player.send.apply player, clean

  
    

module.exports = {
  start: (io) ->
    match = new Match
    
    io.sockets.on 'connection', (clientSocket) ->
      console.log 'connection'
      match.addPlayer clientSocket
}