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
        shipv = new ShipView model: e, worldView: this
        @subviews.push shipv

      when 'Rocket'
        rv = new RocketView model: e, worldView: this
        @subviews.push rv
      else
        console.error "wtf is a #{e.entityTypeName}?", e

  setupScene: ->
    # set the @scene size
    WIDTH = 800
    HEIGHT = 600

    # set some @camera attributes
    VIEW_ANGLE = 45
    ASPECT = WIDTH / HEIGHT
    NEAR = 0.1
    FAR = 10000

    # create a WebGL renderer, @camera
    # and a @scene
    @camera = new THREE.PerspectiveCamera(VIEW_ANGLE, ASPECT, NEAR, FAR)
    @scene = new THREE.Scene()
    @scene.fog = new THREE.Fog( 0x000000, 3500, 15000 )
    @scene.fog.color.setHSV( 0.51, 0.6, 0.025 )

    @renderer = new THREE.WebGLRenderer( { antialias: true, alpha: true } )
    @renderer.setClearColor( @scene.fog.color, 1 )

    @renderer.gammaInput = true
    @renderer.gammaOutput = true
    @renderer.physicallyBasedShading = true


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

    textureFlare0 = THREE.ImageUtils.loadTexture( "/images/textures/lensflare/lensflare0.png" )
    textureFlare2 = THREE.ImageUtils.loadTexture( "/images/textures/lensflare/lensflare2.png" )
    textureFlare3 = THREE.ImageUtils.loadTexture( "/images/textures/lensflare/lensflare3.png" )
    # lights

    lensFlareUpdateCallback = (object) ->
      f = undefined
      fl = object.lensFlares.length
      flare = undefined
      vecX = -object.positionScreen.x * 2
      vecY = -object.positionScreen.y * 2
      f = 0
      while f < fl
        flare = object.lensFlares[f]
        flare.x = object.positionScreen.x + vecX * flare.distance
        flare.y = object.positionScreen.y + vecY * flare.distance
        flare.rotation = 0
        f++
      object.lensFlares[2].y += 0.025
      object.lensFlares[3].rotation = object.positionScreen.x * 0.5 + 45 * Math.PI / 180

    # lens flares
    addLight = (h, s, v, x, y, z) =>
      light = new THREE.PointLight(0xffffff, 1.5, 4500)
      light.position.set x, y, z
      light.color.setHSV h, s, v
      @scene.add light
      flareColor = new THREE.Color(0xffffff)
      flareColor.copy light.color
      THREE.ColorUtils.adjustHSV flareColor, 0, -0.5, 0.5
      lensFlare = new THREE.LensFlare(textureFlare0, 700, 0.0, THREE.AdditiveBlending, flareColor)
      lensFlare.add textureFlare2, 512, 0.0, THREE.AdditiveBlending
      lensFlare.add textureFlare2, 512, 0.0, THREE.AdditiveBlending
      lensFlare.add textureFlare2, 512, 0.0, THREE.AdditiveBlending
      lensFlare.add textureFlare3, 60, 0.6, THREE.AdditiveBlending
      lensFlare.add textureFlare3, 70, 0.7, THREE.AdditiveBlending
      lensFlare.add textureFlare3, 120, 0.9, THREE.AdditiveBlending
      lensFlare.add textureFlare3, 70, 1.0, THREE.AdditiveBlending
      lensFlare.customUpdateCallback = lensFlareUpdateCallback
      lensFlare.position = light.position
      @scene.add lensFlare
    
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



    
  render: (time) ->
    #@sphere.rotation.x += 0.01;
    #@sphere.rotation.y += 0.01;
    @camera.rotation.y += 0.001;

    view.render && view.render(time) for view in @subviews
    @renderer.render(@scene, @camera);