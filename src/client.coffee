app = require('dyz/Peer')
Game = require('dyz/Game')
game = new Game onServer: false
appview = require('xenon/views/AppView')
window.App = new app game: game
window.AppView = new appview model: window.App