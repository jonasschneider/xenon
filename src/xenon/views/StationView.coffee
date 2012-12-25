Backbone = require 'backbone'
BigAssLensFlare = require 'xenon/helpers/BigAssLensFlare'
THREE = require('three')

module.exports = class StationView extends Backbone.View
  el: true

  initialize: (options) ->
    @worldView = options.worldView
    # set up the sphere vars
    radius = 70
    segments = 16
    rings = 16
    
    sphereMaterial = new THREE.MeshLambertMaterial(color: 0x0000CC, wireframe: true)
    @el = new THREE.Mesh(new THREE.SphereGeometry(radius, segments, rings), sphereMaterial)
    @worldView.scene.add @el

    @light = new THREE.PointLight(0xffffff, 1.5, 4500)
    @model.bind 'change', =>
      @model.applyInterpolatedPosition(@el, 0)
      @model.applyInterpolatedPosition(@light, 0)
    
    @light.color.setHSV 0.55, 0.825, 0.99 # light color
    @worldView.scene.add @light
    @worldView.scene.add (new BigAssLensFlare(@light)).el

  render: (time) ->
    # let's assume stations are stationary
    #@model.applyInterpolatedPosition(@el, time)
    @model.applyInterpolatedPosition(@el, 0)
    @model.applyInterpolatedPosition(@light, 0)