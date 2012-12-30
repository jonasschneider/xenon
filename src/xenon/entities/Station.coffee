Entity = require('dyz/Entity')
Object3D = require('./mixins/Object3D')
CreepAI = require('xenon/ai/CreepAI')

module.exports = class Station extends Entity
  mixins: [Object3D]

  attributeSpecs:
    name:   'Home base'
    color: 0x000000
    
    health: 40000
  
  initialize: ->
    @activeShips = 0
    @first = @collection.getEntitiesOfType('Station').length == 1
    
    if @first
      @c = 0xFF0000 
    else
      @c = 0x0000FF
    #@set color: 0x00FF00
    @set color: @c
    

  update: (playerInput) ->
    #@set color: @c
    for s in @collection.getEntitiesOfType('Station')
      enemy = s if s != this
    
    if @ticks() % 10 == 0# && @activeShips < 100# && false
      @activeShips++
      s = @collection.spawn 'Ship',
        position_x: @get('position_x')
        position_y: @get('position_y')
        position_z: @get('position_z') + 100 + Math.random()*300
        color: @get('color')

      s.ai = new CreepAI(s, enemy)