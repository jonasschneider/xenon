Backbone = require 'backbone'
THREE = require('three')

module.exports = class StationView extends Backbone.View
  el: true

  initialize: (options) ->
    @worldView = options.worldView
    # set up the sphere vars
    radius = 200
    segments = 16
    rings = 16
    
    sphereMaterial = new THREE.MeshLambertMaterial(color: 0x00FFFF, wireframe: false)
    @el = new THREE.Mesh(new THREE.SphereGeometry(radius, segments, rings), sphereMaterial)
    @worldView.scene.add @el

    #@el.change

  render: (time) ->
    # let's assume stations are stationary
    #@model.applyInterpolatedPosition(@el, time)
    @model.applyInterpolatedPosition(@el, 0)