Backbone = require 'backbone'
BigAssLensFlare = require 'xenon/helpers/BigAssLensFlare'
THREE = require('three')

module.exports = class StationView extends Backbone.View
  el: true

  initialize: (options) ->
    @worldView = options.worldView
    radius = 670
    segments = 4
    rings = 4
    
    @material = new THREE.MeshBasicMaterial color:0x00FF00, wireframe: true
    @el = new THREE.Mesh(new THREE.SphereGeometry(radius, segments, rings), @material)    
    @light = new THREE.PointLight(0xffffff, 1.5, 4500)

    @model.bind 'change', @updateProps, this
    @updateProps()

    @worldView.scene.add @el
    @worldView.scene.add @light
    @worldView.scene.add (new BigAssLensFlare(@light)).el

  updateProps: ->
    c = new THREE.Color @model.get('color')
    @model.applyInterpolatedPosition(@el, 0)
    @model.applyInterpolatedPosition(@light, 0)
    @material.color = @light.color = c