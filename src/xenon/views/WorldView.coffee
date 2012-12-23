Backbone = require 'backbone'

module.exports = class GameView extends Backbone.View
  initialize: (options) ->
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


    # set up the sphere vars
    radius = 50
    segments = 16
    rings = 16

    # create a new mesh with
    # sphere geometry - we will cover
    # the sphereMaterial next!
    sphereMaterial = new THREE.MeshLambertMaterial(color: 0xCC0000)
    @sphere = sphere = new THREE.Mesh(new THREE.SphereGeometry(radius, segments, rings), sphereMaterial)

    # add the sphere to the @scene
    @scene.add sphere


    # create the sphere's material
    

    # create a point light
    pointLight = new THREE.PointLight(0xFFFFFF)

    # set its position
    pointLight.position.x = 10
    pointLight.position.y = 50
    pointLight.position.z = 130

    # add to the @scene
    @scene.add pointLight
    
  render: (time) ->
    @sphere.rotation.x += 0.01;
    @sphere.rotation.y += 0.01;

    @renderer.render(@scene, @camera);