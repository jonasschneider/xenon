Entity = require('dyz/Entity')

module.exports = class Ship extends Entity
  attributeSpecs:
    name:   'Unknown Ship'
    x:      0
    y:      0
    size:   0

    xrot: 0.0

    health: 100

  update: ->
    @set
      xrot: ((@get('xrot') || 0) + 0.05)