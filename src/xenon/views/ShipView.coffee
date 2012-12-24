Backbone = require 'backbone'

module.exports = class ShipView extends Backbone.View
  el: true

  initialize: (options) ->
    @worldView = options.worldView
    # set up the sphere vars
    radius = 50
    segments = 16
    rings = 16
    
    sphereMaterial = new THREE.MeshLambertMaterial(color: 0xCC0000, wireframe: true)
    @el = new THREE.Mesh(new THREE.SphereGeometry(radius, segments, rings), sphereMaterial)
    @prev = 0
    @worldView.scene.add @el

  render: (time) ->
    @el.rotation.x = @model.interpolate 'xrot', time
    @el.position.x = @model.interpolate 'x', time

    @prev = @model.interpolate 'x', time