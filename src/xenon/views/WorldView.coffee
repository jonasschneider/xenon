Backbone = require 'backbone'
ShipView = require './ShipView'
RocketView = require './RocketView'
StationView = require './StationView'
PlanetView = require './PlanetView'
BulletView = require './BulletView'
BigAssLensFlare = require 'xenon/helpers/BigAssLensFlare'
$ = require('jquery')
THREE = require('three')

SCREEN_WIDTH = window.innerWidth
SCREEN_HEIGHT = window.innerHeight

module.exports = class GameView extends Backbone.View
  initialize: (options) ->
    @setupScene()
    @initComposer()
    @model.bind 'spawn', @addEntity,  this
    @subviews = []

  addEntity: (e) ->
    console.log "spawned entity", e
    switch e.entityTypeName
      when 'Ship'
        shipv = new ShipView model: e, worldView: this
        @subviews.push shipv

      when 'Rocket'
        rv = new RocketView model: e, worldView: this
        @subviews.push rv

      when 'Bullet'
        rv = new BulletView model: e, worldView: this
        @subviews.push rv

      when 'Station'
        sv = new StationView model: e, worldView: this
        @subviews.push sv

      when 'Planet'
        sv = new PlanetView model: e, worldView: this
        @subviews.push sv
      when 'Player'
        # nothing to do
      else
        console.error "wtf is a #{e.entityTypeName}?", e

  setupScene: ->
    # set some @camera attributes
    VIEW_ANGLE = 45
    ASPECT = SCREEN_WIDTH / SCREEN_HEIGHT
    NEAR = 0.1
    FAR = 10000

    # create a WebGL renderer, @camera
    # and a @scene
    @camera = new THREE.PerspectiveCamera(VIEW_ANGLE, ASPECT, NEAR, FAR)
    @scene = new THREE.Scene()
    @scene.fog = new THREE.Fog( 0x000000, 3500, 15000 )
    @scene.fog.color.setHSV( 0.51, 0.6, 0.025 )

    @renderer = new THREE.WebGLRenderer
      #antialias: true
      #alpha: true
    @renderer.setClearColor( @scene.fog.color, 1 )

    #@renderer.gammaInput = true
    #@renderer.gammaOutput = true
    #@renderer.physicallyBasedShading = true

    # add the @camera to the @scene
    @scene.add @camera

    # the @camera starts at 0,0,0 so pull it back
    @camera.position.z = 300

    # start the renderer
    @renderer.setSize SCREEN_WIDTH, SCREEN_HEIGHT

    # attach the render-supplied DOM element
    @el = @renderer.domElement
    $(@el).css(position: 'absolute', top: 0, left: 0, zIndex: -1)

    # create a point light
    pointLight = new THREE.PointLight(0xFFFFFF)

    # set its position
    pointLight.position.x = 10
    pointLight.position.y = 50
    pointLight.position.z = 130
    
    # add to the @scene
    #@scene.add pointLight

    # add the sky dome
    skymap = THREE.ImageUtils.loadTexture '/images/sky.jpg' 
    skymaterial = new THREE.MeshBasicMaterial
      map: skymap
      #transparent: true
      side: THREE.DoubleSide
      #depthTest: false

    skygeo = new THREE.CubeGeometry( 9000, 9000, 9000 )
    skymesh = new THREE.Mesh(skygeo, skymaterial)
    skymesh.position.x = 20
    @scene.add skymesh

    s = 100

    cube = new THREE.CubeGeometry(s, s, s)
    cubemat = new THREE.MeshPhongMaterial
      ambient: 0x333333
      color: 0xffffff
      specular: 0xffffff
      shininess: 50
    i = 0

    while i < 3000
      mesh = new THREE.Mesh(cube, cubemat)
      mesh.position.x = 8000 * (2.0 * Math.random() - 1.0)
      mesh.position.y = 8000 * (2.0 * Math.random() - 1.0)
      mesh.position.z = 8000 * (2.0 * Math.random() - 1.0)
      mesh.rotation.x = Math.random() * Math.PI
      mesh.rotation.y = Math.random() * Math.PI
      mesh.rotation.z = Math.random() * Math.PI
      mesh.matrixAutoUpdate = false
      mesh.updateMatrix()
      @scene.add mesh
      i++

    # lens flares
    addLight = (h, s, v, x, y, z) =>
      light = new THREE.PointLight(0xffffff, 1.5, 4500)
      light.position.set x, y, z
      light.color.setHSV h, s, v
      @scene.add light
      @scene.add (new BigAssLensFlare(light)).el
    
    ambient = new THREE.AmbientLight(0xffffff)
    ambient.color.setHSV 0.1, 0.5, 0.3
    @scene.add ambient
    
    dirLight = new THREE.DirectionalLight(0xffffff, 0.125)
    dirLight.position.set(0, -1, 0).normalize()
    dirLight.color.setHSV 0.1, 0.725, 0.9
    @scene.add dirLight

    addLight 0.55, 0.825, 0.99, 5000, 0, -1000
    addLight 0.08, 0.825, 0.99, 500, 10, -1000
    addLight 0.995, 0.025, 0.99, 5000, 5000, -1000

  
  initComposer: ->
    @renderer.autoClear = false
    renderTargetParameters =
      minFilter: THREE.LinearFilter
      magFilter: THREE.LinearFilter
      #format: THREE.RGBAFormat
      stencilBufer: false

    renderTarget = new THREE.WebGLRenderTarget(SCREEN_WIDTH, SCREEN_HEIGHT, renderTargetParameters)
    renderModel = new THREE.RenderPass(@scene, @camera)
    effectBloom = new THREE.BloomPass(1.2)
    effectBleach = new THREE.ShaderPass(THREE.BleachBypassShader)
    effectFilm = new THREE.FilmPass(0.25, 0.25, 2048, false)
    effectBleach.uniforms["opacity"].value = 0.6
    effectFilm.renderToScreen = true


    effectFXAA = new THREE.ShaderPass THREE.FXAAShader
    effectFXAA.uniforms["resolution"].value.set 1 / SCREEN_WIDTH, 1 / SCREEN_HEIGHT
    
    @composer = new THREE.EffectComposer(@renderer, renderTarget)
    @composer.addPass renderModel
    @composer.addPass effectFXAA
    @composer.addPass effectBloom
    @composer.addPass effectBleach
    @composer.addPass effectFilm
    
  render: (time, delta) ->
    #@sphere.rotation.x += 0.01;
    #@sphere.rotation.y += 0.01;
    @camera.rotation.y += 0.001;

    # terribly inefficient
    remains = []
    i = -1
    for view in @subviews
      i++
      if @model.entitiesById[view.model.id] # entity still exists
        view.render && view.render(time)
        remains.push view

    @subviews = remains


    #@renderer.render(@scene, @camera)
    @composer.render(delta)