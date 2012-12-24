Entity = require('dyz/Entity')
Object3D = require('./mixins/Object3D')

module.exports = class Ship extends Entity
  mixins: [Object3D]

  attributeSpecs:
    name:   'Unknown Ship'
    size:   0

    health: 100

  update: (playerInput) ->
    vx = @get('velocity_x')
    ax = 5
    
    if playerInput["Player0"] && playerInput["Player0"]["move"]["forward"] == 1
      vx += ax if @get('velocity_x') < 100
    else
      vx -= ax if @get('velocity_x') > 0

    if playerInput["Player0"] && playerInput["Player0"]["move"]["back"] == 1 
      vx -= ax if @get('velocity_x') > -100
    else
      vx += ax if @get('velocity_x') < 0

    @set
      rotation_x: @get('rotation_x') + 0.05
      position_x: @get('position_x') + vx
      velocity_x: vx