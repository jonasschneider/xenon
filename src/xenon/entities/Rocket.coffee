Entity = require('dyz/Entity')
Object3D = require('./mixins/Object3D')
THREE = require('three')

module.exports = class Rocket extends Entity
  mixins: [Object3D]

  initialize: ->
    @fuel = 100

  attributeSpecs:
    health: 100

    #damage: 0
    
  update: ->
    movement = new THREE.Vector3(65, 0, 0)
    #o = input["orientation"]
    #quat = new THREE.Quaternion(o.x, o.y, o.z, o.w)
    #quat.multiplyVector3(movement)
    @fuel -= 1
    @set
      position_x: @get('position_x') + @get('velocity_x')
      position_y: @get('position_y') + @get('velocity_y')
      position_z: @get('position_z') + @get('velocity_z')
      
      dead: (@get('health') <= 0 || @fuel <= 0 )