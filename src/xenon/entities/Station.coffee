Entity = require('dyz/Entity')
Object3D = require('./mixins/Object3D')

module.exports = class Station extends Entity
  mixins: [Object3D]

  attributeSpecs:
    name:   'Home base'
    
    health: 40000
  
  initialize: ->
    @activeShips = 0

  update: (playerInput) ->
    if @ticks() % 10 == 0 && @activeShips < 30 
      @activeShips++
      @collection.spawn 'Ship',
        position_x: @get('position_x')
        position_y: @get('position_y')
        position_z: @get('position_z') + 100 + Math.random()*300

        velocity_x: 10