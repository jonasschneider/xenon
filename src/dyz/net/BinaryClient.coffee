#BinaryClient = require('binaryjs-client').BinaryClient

module.exports = class BinaryJSClient
  constructor: (Game) ->
    @game = new Game

  connect: ->
    # TODO: are Binary.js streams really framed?
    console.log("connecting..")
    console.warn "faking latency"
    fakeLagDown = 90
    fakeLagUp = 130
    #fakeLagDown = fakeLagUp = 0
    #client = new BinaryClient
    client = new WebSocket('ws://'+location.host+'/binary')
    client.onopen = =>
      console.log 'connected to server'

      @game.bind 'publish', (e) =>
        setTimeout =>
          #todo
          client.send JSON.stringify(['input', e])
        , fakeLagUp

    client.onmessage = (e) =>
      data = e.data
      #console.warn "onmessage '#{data}'", data, arguments, typeof data

      if typeof data != 'string'
        console.warn 'binary'
      else
        data = JSON.parse(data)
        
        switch data[0] 
          when 'update'
            setTimeout =>
              @game.trigger 'update', data[1]
            , fakeLagDown
          
          when 'log'
            console.log 'Server says:', data[1]

          when 'ping'
            client.send JSON.stringify(['pong', data[1]])

          when 'applySnapshotAndRun'
            @game.world.applyFullSnapshot(data[1])
            @game.lastAppliedUpdateTicks = @game.ticks = data[2]
            @game.run()

          when 'setLocalPlayerId'
            @localPlayerId = data[1]

          else
            console.error("unrecognized")
