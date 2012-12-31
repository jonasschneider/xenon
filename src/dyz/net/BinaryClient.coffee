
module.exports = class BinaryJSClient
  constructor: (Game) ->
    @game = new Game useBinary: true

  connect: ->
    w = new Worker('/src/dyz/net/binary_client_worker.js')
    w.onerror = ->
      console.log 'onerror', arguments
    
    fakeLagDown = 90
    fakeLagUp = 130

    send = (data) ->
      w.postMessage ['send', data]

    @game.bind 'publish', (e) =>
      setTimeout =>
        send ['input', e]
      , fakeLagUp

    w.onmessage = (e) ->
      if e.data[0] == 'consume'
        consume(e.data[1], e.data[2], e.data[3])
      else
        console.error e
        throw 'wat'

    consume = (data, bytesReadCompressed, bytesReadUnompressed)  =>
      switch data[0] 
        when 'update'
          setTimeout =>
            @game.trigger 'update', data[1], bytesReadCompressed, bytesReadUnompressed
          , fakeLagDown
        
        when 'log'
          console.log 'Server says:', data[1]

        when 'ping'
          send ['pong', data[1]]

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
