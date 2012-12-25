Backbone = require('backbone')
_       = require 'underscore'

module.exports = class Peer extends Backbone.Model
  urlRoot: '/app'
  
  initialize: (options) ->
    @game = options.game
    
    @game.bind 'publish', (e) =>
      @trigger 'publish',
        game: e
    
    @bind 'publish', (e) =>
      @game.log "app sending update: "+JSON.stringify(e)
    
    @bind 'update', (e) => 
      #console.log("app getting update: "+JSON.stringify e)
      
      #@is_publishing = false
      if e.game?
        _.extend(e.game, player: e.player) if e.player # used by server to identify client
        @game.trigger 'update', e.game
      @set e.set if e.set?
      #@is_publishing = true