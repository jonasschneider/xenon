Backbone = require 'backbone'

module.exports = class ShipView extends Backbone.View
  el: true

  initialize: ->
    # set up the sphere vars
    radius = 50
    segments = 16
    rings = 16

    @el = new THREE.Mesh(new THREE.SphereGeometry(radius, segments, rings), sphereMaterial)
    sphereMaterial = new THREE.MeshLambertMaterial(color: 0xCC0000)

  render: (time) ->
    @el.rotation.x = @model.interpolate 'xrot', time
