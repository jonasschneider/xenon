app = require('../client/webserver').app
port = process.env.PORT || 2000

process.on 'SIGHUP', ->
  process.exit(0)

server = require('http').createServer(app)
server.listen(port)

requirejs = require('requirejs');
requirejs.config
  baseUrl: 'compiled'
  nodeRequire: require

requirejs(['dyz/net/BinaryServer', 'xenon/GameOnServer'], (BinaryServer, Game) ->
  BinaryServer.start(server, Game)
  console.log("Server running at port " + port)
)