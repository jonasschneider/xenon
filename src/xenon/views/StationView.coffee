Backbone = require 'backbone'
BigAssLensFlare = require 'xenon/helpers/BigAssLensFlare'
THREE = require('three')

module.exports = class StationView extends Backbone.View
  el: true

  initialize: (options) ->
    @worldView = options.worldView
    # set up the sphere vars
    radius = 370
    segments = 16
    rings = 16
    
    @material = new THREE.MeshLambertMaterial color: @model.get('color') || 0x00FF00, wireframe: true
    @el = new THREE.Mesh(new THREE.SphereGeometry(radius, segments, rings), @material)
    @worldView.scene.add @el

    @light = new THREE.PointLight(0xffffff, 1.5, 4500)
    @model.bind 'change', =>
      @model.applyInterpolatedPosition(@el, 0)
      @model.applyInterpolatedPosition(@light, 0)
      @material.color = new THREE.Color @model.get('color')
      @light.color = new THREE.Color @model.get('color')
    @model.applyInterpolatedPosition(@el, 0)
    @model.applyInterpolatedPosition(@light, 0)
    @light.color = new THREE.Color @model.get('color')
    @worldView.scene.add @light
    @worldView.scene.add (new BigAssLensFlare(@light)).el

  render: (time) ->
    # let's assume stations are stationary
    #@model.applyInterpolatedPosition(@el, time)
    #@model.applyInterpolatedPosition(@el, 0)
    #@model.applyInterpolatedPosition(@light, 0)