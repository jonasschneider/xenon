Backbone = require 'backbone'

module.exports = class RocketView extends Backbone.View
  el: true

  initialize: (options) ->
    @worldView = options.worldView
    # set up the sphere vars
    radius = 50
    segments = 16
    rings = 16

    @el = new THREE.Mesh(new THREE.SphereGeometry(radius, segments, rings), sphereMaterial)
    sphereMaterial = new THREE.MeshLambertMaterial(color: 0xCC0000)
    @worldView.scene.add @el
    @prev = 0

  render: (time) ->
    @el.position.x = @model.interpolate 'pos_x', time
    @el.position.z = @model.interpolate 'pos_z', time