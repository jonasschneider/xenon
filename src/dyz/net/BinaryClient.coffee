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
    #compressionStream = new (require('lzw').Stream)
    @bytesReadCompressed = 0
    @bytesReadUncompressed = 0
    @inflater = new (require('inflater'))
    buffer = ''

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
      throw "no arraybuffer" unless raw instanceof ArrayBuffer
      @bytesReadCompressed += raw.byteLength

      #console.info "received #{raw.byteLength}, total #{@bytesReadCompressed}"
      
      uncompressedData = @inflater.append new Uint8Array(raw)
      throw 'inflate failed' if uncompressedData == -1
      string = String.fromCharCode.apply(null, uncompressedData)
      @bytesReadUncompressed += string.length
      buffer += string
      
      while (match = /(\d+)\|(.*)/.exec(buffer)) && match[2].length.toString() == match[1]
        # Yep, we have enough stuff in the buffer
        offset = match[1].length+1
        len = parseInt(match[1])

        consume buffer.substring(offset,offset+len)
        buffer = buffer.substring(offset+len)

    consume = (string) =>
      try 
        data = JSON.parse string
      catch e
        console.log string
        throw e
      
      switch data[0] 
        when 'update'
          c = @bytesReadCompressed
          u = @bytesReadUncompressed
          @bytesReadCompressed = @bytesReadUncompressed = 0
          
          setTimeout =>
            @game.trigger 'update', data[1], c, u

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
