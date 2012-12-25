THREE = require('three')

_ = require('underscore')

module.exports = class ShipFlyControls

  @initialState =
    move_left: 0
    move_right: 0
    move_forward: 0
    move_back: 0

    orientation_x: 0
    orientation_y: 0
    orientation_z: 0
    orientation_w: 1

    attack: 0

  constructor: (target) ->
    @target = target
    
    @movementSpeed = 1.0
    @rollSpeed = 0.005
    @dragToLook = false
    @autoForward = false
    @target.useQuaternion = true
    @tmpQuaternion = new THREE.Quaternion()
    @mouseStatus = 0

    @moveState = ShipFlyControls.initialState
    @pitchDown = @yawRight = @rollRight = @pitchUp = @yawLeft = @rollLeft = 0


    @moveVector = new THREE.Vector3(0, 0, 0)
    @rotationVector = new THREE.Vector3(0, 0, 0)

    console.warn("binding ShipFlyControls to #{@target} with ship #{@ship}")
    document.addEventListener "mousemove", _(@mousemove).bind(this), false
    document.addEventListener "mousedown", _(@mousedown).bind(this), false
    document.addEventListener "mouseup", _(@mouseup).bind(this), false
    document.addEventListener "keydown", _(@keydown).bind(this), false
    document.addEventListener "keyup", _(@keyup).bind(this), false
    @updateMovementVector()
    @updateRotationVector()
  
  keydown: (event) ->
    return  if event.altKey
    switch event.keyCode
      when 87
        @moveState.move_forward = 1
      when 83
        @moveState.move_back = 1
      when 65
        @moveState.move_left = 1
      when 68
        @moveState.move_right = 1

      when 32
        @moveState.attack = 1
    @updateMovementVector()
    @updateRotationVector()

  keyup: (event) ->
    switch event.keyCode
      when 87
        @moveState.move_forward = 0
      when 83
        @moveState.move_back = 0
      when 65
        @moveState.move_left = 0
      when 68
        @moveState.move_right = 0

      when 32
        @moveState.attack = 0
    @updateMovementVector()
    @updateRotationVector()

  mousedown: (event) ->
    event.preventDefault()
    event.stopPropagation()
    if @dragToLook
      @mouseStatus++
    else
      switch event.button
        when 0
          @target.moveForward = true
        when 2
          @target.moveBackward = true

  mousemove: (event) ->
    if not @dragToLook or @mouseStatus > 0
      container = @getContainerDimensions()
      halfWidth = container.size[0] / 2
      halfHeight = container.size[1] / 2
      @yawLeft = -((event.pageX - container.offset[0]) - halfWidth) / halfWidth
      @pitchDown = ((event.pageY - container.offset[1]) - halfHeight) / halfHeight
      @updateRotationVector()

  mouseup: (event) ->
    event.preventDefault()
    event.stopPropagation()
    if @dragToLook
      @mouseStatus--
      @yawLeft = @pitchDown = 0
    else
      switch event.button
        when 0
          @moveForward = false
        when 2
          @moveBackward = false
    @updateRotationVector()

  update: (delta) ->
    #moveMult = delta * @movementSpeed
    rotMult = delta * @rollSpeed
    #@target.translateX @moveVector.x * moveMult
    #@target.translateY @moveVector.y * moveMult
    #@target.translateZ @moveVector.z * moveMult
    @tmpQuaternion.set(@rotationVector.x * rotMult, @rotationVector.y * rotMult, @rotationVector.z * rotMult, 1).normalize()
    @target.quaternion.multiplySelf @tmpQuaternion
    @target.matrix.setPosition @target.position
    @target.matrix.setRotationFromQuaternion @target.quaternion
    @target.matrixWorldNeedsUpdate = true

  updateMovementVector: ->
    forward = (if (@moveState.move_forward or (@autoForward and not @moveState.move_back)) then 1 else 0)
    @moveVector.x = (-@moveState.move_left + @moveState.move_right)
    @moveVector.y = (-@moveState.move_down + @moveState.move_up)
    @moveVector.z = (-forward + @moveState.move_back)

  updateRotationVector: ->
    @rotationVector.x = (-@pitchDown + @pitchUp)
    @rotationVector.y = (-@yawRight + @yawLeft)
    @rotationVector.z = (-@rollRight + @rollLeft)

  getContainerDimensions: ->
    size: [window.innerWidth, window.innerHeight]
    offset: [0, 0]
  