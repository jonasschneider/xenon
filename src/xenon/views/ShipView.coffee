Backbone = require 'backbone'
THREE = require('three')

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
    @el.position.x = 0
    @el.position.y = 0
    @el.position.z = 0
    @worldView.scene.add @el

  render: (time) ->
    @model.applyInterpolatedPosition(@el, time)

    #@el.rotation.x = @model.interpolate 'rotation_x', time
    #@model.applyInterpolatedPosition(@worldView.camera, time)