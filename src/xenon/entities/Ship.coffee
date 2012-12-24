Entity = require('dyz/Entity')

module.exports = class Ship extends Entity
  attributeSpecs:
    name:   'Unknown Ship'
    x:      0
    y:      0
    size:   0

    xrot: 0.0

    health: 100

  update: (playerInput) ->
    newx =  @get('x')
    if playerInput["Player0"] && playerInput["Player0"]["move"]["forward"] == 1
      newx += 100
    if playerInput["Player0"] && playerInput["Player0"]["move"]["back"] == 1
      newx -= 100
    @set
      xrot: @get('xrot') + 0.05
      x: newx