#BinaryClient = require('binaryjs-client').BinaryClient

module.exports = class BinaryJSClient
  constructor: (Game) ->
    @game = new Game useBinary: true
    @bytesRead = 0

  connect: ->
    # TODO: are Binary.js streams really framed?
    console.log("connecting..")
    console.warn "faking latency"
    fakeLagDown = 90
    fakeLagUp = 130
    #fakeLagDown = fakeLagUp = 0
    #client = new BinaryClient
    client = new WebSocket('ws://'+location.host+'/binary')
    client.binaryType = 'arraybuffer'

    client.onopen = =>
      console.log 'connected to server'

      @game.bind 'publish', (e) =>
        setTimeout =>
          #todo
          client.send JSON.stringify(['input', e])
        , fakeLagUp

    client.onmessage = (e) =>
      raw = e.data
      
      if typeof raw != 'string'
        @bytesRead += raw.size
        
        setTimeout =>
          @game.trigger 'binary', raw
        , fakeLagDown
      else
        @bytesRead += raw.length
        data = JSON.parse(raw)
        console.warn "onmessage '#{raw}'", data, arguments, typeof data if data[0] != 'update'

        
        switch data[0] 
          when 'update'
            b = @bytesRead
            setTimeout =>
              @game.trigger 'update', data[1], b
            , fakeLagDown
            @bytesRead = 0
          
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
            console.log 'localPlayer set: ', data[1]

          else
            console.error("unrecognized")
