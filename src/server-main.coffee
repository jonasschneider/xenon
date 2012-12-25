#require('webkit-devtools-agent')
socketio = require('socket.io')
app = require('../client/webserver').app
port = process.env.PORT || 2000

process.on 'SIGHUP', ->
  process.exit(0)


server = require('http').createServer(app)

io = socketio.listen(server)

server.listen(port)

requirejs = require('requirejs');

requirejs.config
  baseUrl: 'compiled'
  nodeRequire: require

requirejs(['dyz/net/SocketIOServer', 'xenon/GameOnServer'], (server, Game) ->
  server.start(io, Game)
  console.log("Server running at port " + port)
)