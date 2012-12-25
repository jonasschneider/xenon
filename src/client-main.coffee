XeGame = require('xenon/GameOnClient')
GameView = require('xenon/views/GameView')

Client = require('dyz/net/BinaryClient')
window.xenonClient = client = new Client(XeGame)
window.xenonGameView = view = new GameView model: client.game, client: client

view.bind 'ready', ->
  client.connect()