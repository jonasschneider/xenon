THREE = require('three')

module.exports = FlyControls = (object, domElement) ->
  bind = (scope, fn) ->
    ->
      fn.apply scope, arguments
  @object = object
  @domElement = (if (domElement isnt `undefined`) then domElement else document)
  @domElement.setAttribute "tabindex", -1  if domElement
  @movementSpeed = 1.0
  @rollSpeed = 0.005
  @dragToLook = false
  @autoForward = false
  @object.useQuaternion = true
  @tmpQuaternion = new THREE.Quaternion()
  @mouseStatus = 0
  @moveState =
    up: 0
    down: 0
    left: 0
    right: 0
    forward: 0
    back: 0
    pitchUp: 0
    pitchDown: 0
    yawLeft: 0
    yawRight: 0
    rollLeft: 0
    rollRight: 0

  @moveVector = new THREE.Vector3(0, 0, 0)
  @rotationVector = new THREE.Vector3(0, 0, 0)
  @handleEvent = (event) ->
    this[event.type] event  if typeof this[event.type] is "function"

  @keydown = (event) =>
    return  if event.altKey
    switch event.keyCode
      when 16
        @movementSpeedMultiplier = .1
      when 87
        @moveState.forward = 1
      when 83
        @moveState.back = 1
      when 65
        @moveState.left = 1
      when 68
        @moveState.right = 1
      when 82
        @moveState.up = 1
      when 70
        @moveState.down = 1
      when 38
        @moveState.pitchUp = 1
      when 40
        @moveState.pitchDown = 1
      when 37
        @moveState.yawLeft = 1
      when 39
        @moveState.yawRight = 1
      when 81
        @moveState.rollLeft = 1
      when 69
        @moveState.rollRight = 1
    @updateMovementVector()
    @updateRotationVector()

  @keyup = (event) =>
    switch event.keyCode
      when 16
        @movementSpeedMultiplier = 1
      when 87
        @moveState.forward = 0
      when 83
        @moveState.back = 0
      when 65
        @moveState.left = 0
      when 68
        @moveState.right = 0
      when 82
        @moveState.up = 0
      when 70
        @moveState.down = 0
      when 38
        @moveState.pitchUp = 0
      when 40
        @moveState.pitchDown = 0
      when 37
        @moveState.yawLeft = 0
      when 39
        @moveState.yawRight = 0
      when 81
        @moveState.rollLeft = 0
      when 69
        @moveState.rollRight = 0
    @updateMovementVector()
    @updateRotationVector()

  @mousedown = (event) =>
    console.info "mousedown"
    @domElement.focus()  if @domElement isnt document
    event.preventDefault()
    event.stopPropagation()
    if @dragToLook
      @mouseStatus++
    else
      switch event.button
        when 0
          @object.moveForward = true
        when 2
          @object.moveBackward = true

  @mousemove = (event) =>
    if not @dragToLook or @mouseStatus > 0
      container = @getContainerDimensions()
      halfWidth = container.size[0] / 2
      halfHeight = container.size[1] / 2
      @moveState.yawLeft = -((event.pageX - container.offset[0]) - halfWidth) / halfWidth
      @moveState.pitchDown = ((event.pageY - container.offset[1]) - halfHeight) / halfHeight
      @updateRotationVector()

  @mouseup = (event) =>
    event.preventDefault()
    event.stopPropagation()
    if @dragToLook
      @mouseStatus--
      @moveState.yawLeft = @moveState.pitchDown = 0
    else
      switch event.button
        when 0
          @moveForward = false
        when 2
          @moveBackward = false
    @updateRotationVector()

  @update = (delta) ->
    moveMult = delta * @movementSpeed
    rotMult = delta * @rollSpeed
    @object.translateX @moveVector.x * moveMult
    @object.translateY @moveVector.y * moveMult
    @object.translateZ @moveVector.z * moveMult
    @tmpQuaternion.set(@rotationVector.x * rotMult, @rotationVector.y * rotMult, @rotationVector.z * rotMult, 1).normalize()
    @object.quaternion.multiplySelf @tmpQuaternion
    @object.matrix.setPosition @object.position
    @object.matrix.setRotationFromQuaternion @object.quaternion
    @object.matrixWorldNeedsUpdate = true

  @updateMovementVector = ->
    forward = (if (@moveState.forward or (@autoForward and not @moveState.back)) then 1 else 0)
    @moveVector.x = (-@moveState.left + @moveState.right)
    @moveVector.y = (-@moveState.down + @moveState.up)
    @moveVector.z = (-forward + @moveState.back)

  @updateRotationVector = ->
    @rotationVector.x = (-@moveState.pitchDown + @moveState.pitchUp)
    @rotationVector.y = (-@moveState.yawRight + @moveState.yawLeft)
    @rotationVector.z = (-@moveState.rollRight + @moveState.rollLeft)

  @getContainerDimensions = ->
    unless @domElement is document
      size: [@domElement.offsetWidth, @domElement.offsetHeight]
      offset: [@domElement.offsetLeft, @domElement.offsetTop]
    else
      size: [window.innerWidth, window.innerHeight]
      offset: [0, 0]
  
  console.warn("binding FlyControls to #{@domElement}")
  @domElement.addEventListener "mousemove",  @mousemove, false
  @domElement.addEventListener "mousedown", @mousedown, false
  @domElement.addEventListener "mouseup", @mouseup, false
  @domElement.addEventListener "keydown", @keydown, false
  @domElement.addEventListener "keyup", @keyup, false
  @updateMovementVector()
  @updateRotationVector()