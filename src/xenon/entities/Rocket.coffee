Entity = require('dyz/Entity')

module.exports = class Rocket extends Entity
  attributeSpecs:
    pos_x: 0
    pos_y: 0
    pos_z: 0

    health: 100

  update: ->
    @set
      pos_x: (@get('pos_x') + 10)
      pos_z: (@get('pos_z') - 10)
      health: (@get('health') - 1)
      dead: (@get('health') == 0)