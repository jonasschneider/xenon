module.exports = Object3D =
  attributeSpecs:
    position_x: 0
    position_y: 0
    position_z: 0

    velocity_x: 0
    velocity_y: 0
    velocity_z: 0

    rotation_x: 0
    rotation_y: 0
    rotation_z: 0
  
  methods:
    # Apply the interpolated 3D position to a THREE.js mesh
    # (or anything that has a position vector property)
    applyInterpolatedPosition: (el, time) ->
      el.position.x = @interpolate 'position_x', time
      el.position.y = @interpolate 'position_y', time
      el.position.z = @interpolate 'position_z', time