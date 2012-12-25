Client = require('dyz/net/SocketIOClient')
XeGame = require('xenon/GameOnClient')
GameView = require('xenon/views/GameView')

window.xenonClient = client = new Client(XeGame)
window.xenonGameView = view = new GameView model: client.game, client: client

view.bind 'ready', ->
  client.connect()