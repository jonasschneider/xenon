Backbone = require 'backbone'

module.exports = class StationView extends Backbone.View
  el: true

  initialize: (options) ->
    @worldView = options.worldView
    # set up the sphere vars
    radius = 50
    segments = 16
    rings = 16
    
    sphereMaterial = new THREE.MeshLambertMaterial(color: 0xCC0000, wireframe: true)
    @el = new THREE.Mesh(new THREE.SphereGeometry(radius, segments, rings), sphereMaterial)
    @worldView.scene.add @el
    @prev = 0

  render: (time) ->
    @el.position.y = 10

