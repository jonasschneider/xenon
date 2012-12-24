_                 = require 'underscore'
DyzGameOnServer = require 'dyz/GameOnServer'
consts = require './index'

module.exports = class GameOnServer extends DyzGameOnServer
  entityTypes: consts.entityTypes

  addShip: (attributes) ->
    @world.spawn 'Ship', attributes
  
  moveStuff: ->
    _(@world.getEntitiesOfType('Ship')).each (ship) ->
      ship.set xrot: ship.get('xrot') + 0.5