Backbone = require 'backbone'
THREE = require('three')

module.exports = class BulletView extends Backbone.View
  el: true

  initialize: (options) ->
    @worldView = options.worldView
    # set up the sphere vars
    radius = 30
    segments = 16
    rings = 16

    sphereMaterial = new THREE.MeshLambertMaterial(color: 0xCC0000, wireframe: true)
    @el = new THREE.Mesh(new THREE.SphereGeometry(radius, segments, rings), sphereMaterial)
    
    @worldView.scene.add @el
    @prev = 0

  render: (time) ->
    #ticksInFlight = @model.ticks() - @model.get('launchTime')
    #@model.applyInterpolatedPosition(@el, time)
    if @model.collection.entitiesById[@model] # hack to check if entity isn't dead
      p = @model.interpolatedPosition(time)

      @el.position.x = p.x
      @el.position.y = p.y
      @el.position.z = p.z