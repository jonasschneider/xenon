_                 = require 'underscore'
DyzGame = require 'dyz/game'

module.exports = class Game extends DyzGame
  addShip: (attributes) ->
    @world.spawn 'Ship', attributes
  
  moveStuff: ->
    _(@world.getEntitiesOfType('Ship')).each (ship) ->
      ship.set xrot: ship.get('xrot') + 0.5
