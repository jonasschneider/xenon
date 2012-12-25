Entity = require('dyz/Entity')

module.exports = class Player extends Entity
  attributeSpecs:
    clientId: 0
    name: 'Jack'

    boarded_ship_id: 0

  board: (ship) ->
    ship.setRelation 'boarded_by', this
    this.setRelation 'boarded_ship', ship