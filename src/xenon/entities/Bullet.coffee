Entity = require('dyz/Entity')
BallisticObject3D = require('./mixins/BallisticObject3D')
THREE = require('three')

module.exports = class Bullet extends Entity
  mixins: [BallisticObject3D]
  
  initialize: ->
    @fuel = 100

  attributeSpecs:
    # position_{x,y,z} is the launch position
    health: 100
    launchTime: 0

    #damage: 0
  interpolatedPosition: (time) ->
    startPos = new THREE.Vector3 @get('position_x'), @get('position_y'), @get('position_z')
    trajectory = new THREE.Vector3 @get('velocity_x'), @get('velocity_y'), @get('velocity_z')
    fraction = (time - @collection.tickStartedAt) / @collection.tickLength
    trajectory.multiplyScalar @ticks()-@get('launchTime') + fraction

    startPos.addSelf(trajectory)

  update: ->
    #@interpolatedPosition()
    #movement = new THREE.Vector3(65, 0, 0)
    #o = input["orientation"]
    #quat = new THREE.Quaternion(o.x, o.y, o.z, o.w)
    #quat.multiplyVector3(movement)
    @fuel -= 1
    if @get('health') <= 0 || @fuel <= 0
      @set dead: true