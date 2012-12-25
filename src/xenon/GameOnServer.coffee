_                 = require 'underscore'
DyzGameOnServer = require 'dyz/GameOnServer'
consts = require './index'

module.exports = class GameOnServer extends DyzGameOnServer
  entityTypes: consts.entityTypes

  loadMap: ->
    @world.spawn 'Station', position_x: 500, position_z: -2000, position_y: 100
    @world.spawn 'Station', position_x: -500, position_z: -2000, position_y: 100

  onPlayerJoin: (internalPlayer) ->
    @tellSelf('spawnPlayerShip', internalPlayer)

  spawnPlayerShip: (internalPlayer) ->
    player = @world.spawn 'Player', name: internalPlayer.name, clientId: internalPlayer.id
    ship = @world.spawn 'Ship', name: internalPlayer.name
    player.board(ship)

  moveStuff: ->
    _(@world.getEntitiesOfType('Ship')).each (ship) ->
      ship.set xrot: ship.get('xrot') + 0.5

  shootStuff: ->
    @world.spawn 'Rocket'
