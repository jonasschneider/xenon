Backbone = require 'backbone'
THREE = require('three')
ExplosionView = require('./ExplosionView')

module.exports = class ShipView extends Backbone.View
  el: true

  initialize: (options) ->
    @worldView = options.worldView
    # set up the sphere vars
    radius = 100
    segments = 16
    rings = 16
    
    @material = new THREE.MeshLambertMaterial(color:  0xFF0000, wireframe: true)

    @el = new THREE.Mesh(new THREE.SphereGeometry(radius, segments, rings), @material)
    @el.position.x = 0
    @el.position.y = 0
    @el.position.z = 0
    @worldView.scene.add @el

    @model.bind 'remove', =>
      @dead = true
      @worldView.scene.remove @el
    
    @model.bind 'explode', =>
      pos = new THREE.Vector3 @model.get('position_x'), @model.get('position_y'), @model.get('position_z')
      @worldView.subviews.push new ExplosionView worldView: @worldView, pointOfExplosion: pos, baseColor: @model.get('color')

    @model.bind 'damage', =>
      pos = new THREE.Vector3 @model.get('position_x'), @model.get('position_y'), @model.get('position_z')
      @worldView.subviews.push new ExplosionView worldView: @worldView, pointOfExplosion: pos, baseColor: @model.get('color'), size: 0.3

    @model.bind 'change', =>
      c = @model.get('color') || 0x00FF00
      @material.color = new THREE.Color c
    

  render: (time) ->
    @model.applyInterpolatedPosition(@el, time)

    #@el.rotation.x = @model.interpolate 'rotation_x', time
    #@model.applyInterpolatedPosition(@worldView.camera, time)