importScripts('/src/require.js')
require.config baseUrl: "/src"
g = this
require ['inflater'], (Inflater) ->
  @bytesReadCompressed = 0
  @bytesReadUncompressed = 0
  @inflater = new Inflater
  buffer = ''

  client = new WebSocket('ws://'+location.host+'/binary')
  client.binaryType = 'arraybuffer'

  client.onopen = ->
    g.onmessage = (e) ->
      if e.data[0] == 'send'
        client.send JSON.stringify(e.data[1])
      else
        throw 'wat'+ JSON.stringify(e.data)
  
  consume = (string) ->
    data = JSON.parse string
    g.postMessage ['consume', data, @bytesReadCompressed, @bytesReadUncompressed]
    @bytesReadCompressed = @bytesReadUncompressed = 0

  client.onmessage = (e) =>
    raw = e.data
    throw "no arraybuffer" unless raw instanceof ArrayBuffer
    @bytesReadCompressed += raw.byteLength

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
