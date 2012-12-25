Entity = require('dyz/Entity')
Object3D = require('./mixins/Object3D')
THREE = require('three')

module.exports = class Ship extends Entity
  mixins: [Object3D]

  attributeSpecs:
    name:   'Unknown Ship'
    size:   0
    
    health: 100
    boarded_by_id: 0


  update: (playerInput) ->
    # get the input from the ship's owner
    return unless @getRelation('boarded_by') && input = playerInput[@getRelation('boarded_by').get('clientId')]
    
    vx = @get('velocity_x')
    ax = 5

    vz = @get('velocity_z')
    az = 5

    vy = 0
    
    if input["move"]["forward"] == 1 
      vz -= az if @get('velocity_z') > -100
    else
      vz += az if @get('velocity_z') < 0

    if input["move"]["back"] == 1
      vz += az if @get('velocity_z') < 100
    else
      vz -= az if @get('velocity_z') > 0

    if input["move"]["right"] == 1
      vx += ax if @get('velocity_x') < 100
    else
      vx -= ax if @get('velocity_x') > 0

    if input["move"]["left"] == 1 
      vx -= ax if @get('velocity_x') > -100
    else
      vx += ax if @get('velocity_x') < 0

    movement = new THREE.Vector3(vx, vy, vz)
    o = input["orientation"]
    quat = new THREE.Quaternion(o.x, o.y, o.z, o.w)
    quat.multiplyVector3(movement)

    @set
      #rotation_x: @get('rotation_x') + 0.05

      position_x: @get('position_x') + movement.x
      position_y: @get('position_y') + movement.y
      position_z: @get('position_z') + movement.z
      
      velocity_x: vx
      velocity_y: vy
      velocity_z: vz