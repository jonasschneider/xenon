Entity = require('dyz/Entity')
Object3D = require('./mixins/Object3D')
THREE = require('three')

module.exports = class Ship extends Entity
  mixins: [Object3D]

  attributeSpecs:
    name:   'Unknown Ship'
    size:   0
    color:  0x000000
    
    health: 100
    boarded_by_id: 0

  damage: (amount) ->
    h = @get('health')-50
    @set health: h
    
    if h <= 0
      @message 'explode'
      @set dead: true 
    else
      @message 'damage'

  update: (playerInput) ->
    vx = @velocity_x || 0
    ax = 5

    vz = @velocity_z || 0
    az = 5

    vy = 0
    
    movement = new THREE.Vector3(vx, vy, vz)

    getInput = =>
      if @getRelation('boarded_by')
        playerInput[@getRelation('boarded_by').get('clientId')]
      else if @ai
        @ai.getInput()

    # get the input from the ship's owner or from the AI
    if input = getInput()
      if input["move_forward"] == 1 
        vz -= az if @velocity_z > -100
      else
        vz += az if @velocity_z < 0

      if input["move_back"] == 1
        vz += az if @velocity_z < 100
      else
        vz -= az if @velocity_z > 0

      if input["move_right"] == 1
        vx += ax if @velocity_x < 100
      else
        vx -= ax if @velocity_x > 0

      if input["move_left"] == 1 
        vx -= ax if @velocity_x > -100
      else
        vx += ax if @velocity_x < 0

    
      movement = new THREE.Vector3(vx, vy, vz)
      # only use the quaternion when we have a client orientation
      quat = new THREE.Quaternion(input["orientation_x"], input["orientation_y"], input["orientation_z"], input["orientation_w"])
      quat.multiplyVector3(movement)

      if input["attack"]
        if @collection.ticks % 5 == 0
          # rocket position relative to ship
          rocketPos = new THREE.Vector3(0,0,-250 - Math.random()*100)
          quat.multiplyVector3(rocketPos)


          rocketVel = new THREE.Vector3(0,0,-100)
          quat.multiplyVector3(rocketVel)

          @collection.spawn 'Bullet',
            launchTime: @ticks(),
            
            position_x: @get('position_x') + rocketPos.x
            position_y: @get('position_y') + rocketPos.y
            position_z: @get('position_z') + rocketPos.z

            velocity_x: rocketVel.x
            velocity_y: rocketVel.y
            velocity_z: rocketVel.z
    
    @set
      position_x: @get('position_x') + movement.x
      position_y: @get('position_y') + movement.y
      position_z: @get('position_z') + movement.z
    
    @velocity_x = vx
    @velocity_y = vy
    @velocity_z = vz