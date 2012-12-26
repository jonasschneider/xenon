util    = require 'util'
_       = require 'underscore'
Backbone= require 'backbone'

id = 0

class NetworkedPlayer
  constructor: (socket, name) ->
    @socket = socket
    @name = name
    @id = ++id
    
    @sendId()
    @socket.emit 'log', "You are player ##{@id}"

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
  
  sendId: ->
    @socket.emit 'setLocalPlayerId', @id

_.extend(NetworkedPlayer.prototype, Backbone.Events)

class Match
  constructor: (Game) ->
    @players = []
    
    @game = new Game onServer: true
    
    @game.bind 'publish', @distributeUpdate, this
    
    @game.world.enableStrictMode()

    setTimeout =>
      @game.run()
    , 500
  
  addPlayer: (clientSocket) ->
    console.log clientSocket.id + " connected"
    player = new NetworkedPlayer clientSocket, ("Player " + (@players.length + 1))
    @game.onPlayerJoin player
    @players.push player
    
    player.bind 'update', (e) =>
      #player.socket.broadcast.emit 'update', e # security?
      @game.trigger 'update', _.extend(e, player: player.id)
    
    snapshot = @game.world.snapshotFull()
    player.send 'applySnapshotAndRun', snapshot, @game.ticks
  
  distributeUpdate: (update) ->
    @sendToAll('update', update)
  
  sendToAll: ->
    clean = []
    _(arguments).each (arg) ->
      clean.push arg
      
    _(@players).each (player) -> # potential problem since we don't use @game.players
      player.send.apply player, clean

  
    

module.exports = {
  start: (io, Game) ->
    match = new Match(Game)
    io.sockets.on 'connection', (clientSocket) ->
      console.log 'connection'
      match.addPlayer clientSocket
}