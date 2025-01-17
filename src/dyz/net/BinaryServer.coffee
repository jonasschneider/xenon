util    = require 'util'
_       = require 'underscore'
Backbone= require 'backbone'

ws = require 'ws'
zlib = require 'zlib'

id = 0

class NetworkedPlayer
  constructor: (socket, name) ->
    @socket = socket
    @name = name
    @id = ++id

    @deflateStream = zlib.createDeflateRaw(chunkSize: 100*1024)
    @deflateStream._flush = zlib.Z_SYNC_FLUSH # fire 'data' after every write()
    @deflateStream.on 'data', (data) =>
      @socket.send data, binary: true

    @sendId()
    @sendControl 'log', "You are player ##{@id}"

    pingSentAt = null
    pinged = false

    pingSentAt = new Date().getTime()
    @sendControl 'ping', pingSentAt
    
    @socket.on 'message', (data, flags) =>
      data = JSON.parse(data)

      if !pinged
        console.log "received", data, "while waiting for pong" unless data[0] == 'pong'
        @latency = new Date().getTime() - pingSentAt
        @sendControl 'log', "Your RTT is #{@latency}"
        pinged = true

        @trigger 'ready'
      else
        switch data[0]
          when 'input'
            @trigger 'update', data[1]
          else
            console.log data
            throw 'wat'
  
  sendGameData: (d) ->
    @sendControl 'update', d
  
  sendControl: ->
    x = JSON.stringify(arguments)
    @deflateStream.write x.length + "|" + x

  sendId: ->
    @sendControl 'setLocalPlayerId', @id

_.extend(NetworkedPlayer.prototype, Backbone.Events)

class Match
  constructor: (Game) ->
    @players = []
    
    @game = new Game

    @game.bind 'publish', (e) =>
      _(@players).each (player) ->
        player.sendGameData e

    @game.world.enableStrictMode()

    setTimeout =>
      @game.run()
    , 500
  
  addPlayer: (clientSocket) ->
    console.log "client connected"
    player = new NetworkedPlayer clientSocket, ("Player " + (@players.length + 1))
    @game.onPlayerJoin player
    @players.push player
    
    player.bind 'update', (e) =>
      @game.trigger 'update', _.extend(e, player: player.id)
    
    snapshot = @game.world.snapshotFull()
    player.sendControl 'applySnapshotAndRun', snapshot, @game.ticks


module.exports = 
  start: (http, Game) ->
    match = new Match(Game)
    server = new ws.Server(server: http, path: '/binary')

    server.on "connection", (clientSocket) ->
      console.log 'connection accepted'
      match.addPlayer clientSocket