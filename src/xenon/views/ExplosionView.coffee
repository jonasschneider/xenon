THREE = require('three')

module.exports = class ExplosionView
  constructor: (options) ->
    @worldView = options.worldView
    @pointOfExplosion = options.pointOfExplosion
    @size = options.size || 1
    
    @particles = new THREE.Geometry()
    pMaterial = new THREE.ParticleBasicMaterial
      color: 0xFFFFFF
      size: 300*@size
      map: THREE.ImageUtils.loadTexture "/images/particles/ball.png"
      blending: THREE.AdditiveBlending,
      transparent: true
      opacity: 0.5

    #@particleSystem = particleSystem = new THREE.ParticleSystem(@particles, pMaterial)


    for i in [0..50*@size]
      p = new THREE.Vector3 Math.random()*100-50, Math.random()*100-50, Math.random()*100-50

      @particles.vertices.push p
    
    options.baseColor ||= 0xFFFFFF
    basehsv = new THREE.Color(options.baseColor).getHSV()
    mod1 = new THREE.Color().setHSV(basehsv.h, 0.3, 0.3)
    mod2 = new THREE.Color().setHSV(basehsv.h, basehsv.s/3, 0.6)
    mod3 = new THREE.Color().setHSV(basehsv.h, basehsv.s/2, 0.2)
    mod4 = new THREE.Color().setHSV(basehsv.h, basehsv.s/2, 0.4)

    parameters = [
      [mod1.getHex(), 5*@size],
      [mod2.getHex(), 3*@size],
      [mod3.getHex(), 2*@size],
      [mod4.getHex(), 1*@size]
    ]
    #parameters = [ [ 0xff0000, 5 ], [ 0xff3300, 4 ], [ 0xff6600, 3 ], [ 0xff9900, 2 ], [ 0xffaa00, 1 ] ];
    #parameters = [ [ 0xffffff, 5 ], [ 0xdddddd, 4 ], [ 0xaaaaaa, 3 ], [ 0x999999, 2 ], [ 0x777777, 1 ] ];
    materials = []
    @systems = []
    @mats = []

    for [hex, psize] in parameters
      #materials[i] = new THREE.ParticleBasicMaterial( { color: color, size: size } );
      mat = new THREE.ParticleBasicMaterial(size: psize*20)
      mat.color = new THREE.Color hex
      ps = new THREE.ParticleSystem @particles, mat
      ps.rotation.x = Math.random() * 6
      ps.rotation.y = Math.random() * 6
      ps.rotation.z = Math.random() * 6
      ps.position = @pointOfExplosion
      @worldView.scene.add ps
      @systems.push ps
      @mats.push mat
      i++

    @startTime = new Date().getTime()
    #particleSystem.sortParticles = true
    #particleSystem.geometry.verticesNeedUpdate = true
    #@worldView.scene.add particleSystem
    @opac = 1

  die: ->
    @worldView.scene.remove ps for ps in @systems
    @dead = true

  render: (time) ->
    fac = Math.pow(2.4-1/@size, 1+(time - @startTime)/100)
    for ps in @systems
      ps.scale = new THREE.Vector3(1,1,1).multiplyScalar fac*(1+Math.random()*0.2-0.1)

    if fac > 4
      @opac -= 0.01
      mat.opacity = @opac for mat in @mats
    
    @die() if @opac < 0