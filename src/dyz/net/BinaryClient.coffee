#BinaryClient = require('binaryjs-client').BinaryClient

module.exports = class BinaryJSClient
  constructor: (Game) ->
    @game = new Game useBinary: true

  connect: ->
    console.log("connecting..")
    console.warn "faking latency"
    fakeLagDown = 90
    fakeLagUp = 130
    #fakeLagDown = fakeLagUp = 0
    
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
        setTimeout =>
          @game.trigger 'binary', raw
        , fakeLagDown
      else
        data = JSON.parse(raw)
        
        switch data[0] 
          when 'update'
            setTimeout =>
              @game.trigger 'update', data[1], raw.length
            , fakeLagDown
          
          when 'log'
            console.log 'Server says:', data[1]

          when 'ping'
            client.send JSON.stringify(['pong', data[1]])

          when 'applySnapshotAndRun'
            console.log 'applySnapshotAndRun', data[1]
            @game.world.applyFullSnapshot(data[1])
            @game.lastAppliedUpdateTicks = @game.ticks = data[2]
            @game.run()

          when 'setLocalPlayerId'
            @localPlayerId = data[1]
            console.log 'localPlayer set: ', data[1]

          else
            console.error("unrecognized")
