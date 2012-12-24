Entity = require('dyz/Entity')

module.exports = class Ship extends Entity
  attributeSpecs:
    name:   'Unknown Ship'
    x:      0
    y:      0
    size:   0

    vx: 0

    xrot: 0.0

    health: 100

  update: (playerInput) ->
    vx = @get('vx')
    ax = 5
    
    if playerInput["Player0"] && playerInput["Player0"]["move"]["forward"] == 1
      vx += ax if @get('vx') < 100
    else
      vx -= ax if @get('vx') > 0

    if playerInput["Player0"] && playerInput["Player0"]["move"]["back"] == 1 
      vx -= ax if @get('vx') > -100
    else
      vx += ax if @get('vx') < 0

    @set
      xrot: @get('xrot') + 0.05
      x: @get('x') + vx
      vx: vx