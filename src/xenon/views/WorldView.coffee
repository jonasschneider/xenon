Backbone = require 'backbone'
ShipView = require './ShipView'
RocketView = require './RocketView'

module.exports = class GameView extends Backbone.View
  initialize: (options) ->
    @setupScene()
    @model.bind 'spawn', @addEntity,  this
    @subviews = []

  addEntity: (e) ->
    console.log "spawned entity", e
    switch e.entityTypeName
      when 'Ship'
        shipv = new ShipView model: e  
        @scene.add shipv.el
        @subviews.push shipv

      when 'Rocket'
        rv = new RocketView model: e  
        @scene.add rv.el
        @subviews.push rv
      else
        console.error "wtf is a #{e.entityTypeName}?", e

  setupScene: ->
    # set the @scene size
    WIDTH = 400
    HEIGHT = 300

    # set some @camera attributes
    VIEW_ANGLE = 45
    ASPECT = WIDTH / HEIGHT
    NEAR = 0.1
    FAR = 10000

    # create a WebGL renderer, @camera
    # and a @scene
    @renderer = new THREE.WebGLRenderer()
    @camera = new THREE.PerspectiveCamera(VIEW_ANGLE, ASPECT, NEAR, FAR)
    @scene = new THREE.Scene()

    # add the @camera to the @scene
    @scene.add @camera

    # the @camera starts at 0,0,0
    # so pull it back
    @camera.position.z = 300

    # start the renderer
    @renderer.setSize WIDTH, HEIGHT

    # attach the render-supplied DOM element
    @el = @renderer.domElement

    # create a point light
    pointLight = new THREE.PointLight(0xFFFFFF)

    # set its position
    pointLight.position.x = 10
    pointLight.position.y = 50
    pointLight.position.z = 130

    # add to the @scene
    @scene.add pointLight


    
  render: (time) ->
    #@sphere.rotation.x += 0.01;
    #@sphere.rotation.y += 0.01;

    view.render && view.render(time) for view in @subviews
    @renderer.render(@scene, @camera);