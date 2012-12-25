#require('webkit-devtools-agent')
socketio = require('socket.io')
app = require('../client/webserver').app
port = process.env.PORT || 2000

process.on 'SIGHUP', ->
  process.exit(0)


server = require('http').createServer(app)

#io = socketio.listen(server)

server.listen(port)

requirejs = require('requirejs');

requirejs.config
  baseUrl: 'compiled'
  nodeRequire: require

requirejs(['dyz/net/SocketIOServer', 'dyz/net/BinaryServer', 'xenon/GameOnServer'], (IOserver, BinaryServer, Game) ->
  #IOserver.start(io, Game)
  BinaryServer.start(server, Game)
  console.log("Server running at port " + port)
)