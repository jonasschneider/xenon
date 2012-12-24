app = require('dyz/Peer')
Game = require('xenon/GameOnClient')
game = new Game onServer: false
appview = require('xenon/views/AppView')
window.App = new app game: game
window.AppView = new appview model: window.App