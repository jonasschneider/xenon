THREE = require('three')

module.exports = class BulletRenderer
  resetVector: new THREE.Vector3 -1000000, 0,0
  allocateCount: 2000

  constructor: (world) ->
    bullets = []
    @world = world

    @particles = new THREE.Geometry()
    pMaterial = new THREE.ParticleBasicMaterial
      color: 0xFFFFFF
      size: 180
      map: THREE.ImageUtils.loadTexture "/images/particles/ball.png"
      blending: THREE.AdditiveBlending,
      transparent: true
      opacity: 0.7

    @particles.vertices.push @resetVector for i in [0..@allocateCount-1]
    @particleSystem = particleSystem = new THREE.ParticleSystem(@particles, pMaterial)
    #particleSystem.sortParticles = true

    @allocatedBulletVertices = 0

  update: (time) ->
    bullets = @world.getEntitiesOfType('Bullet')
    len = bullets.length

    # If we are over the limit, just don't display any further bullets
    if bullets.length > @particles.vertices.length
      console.error 'not enough particles allocated for bullet display'
      len = @particles.vertices.length

    nextParticle = 0

    # Move the next available particle to the position of each of the bullets
    if len != 0
      for i in [0..len-1]
        bullet = bullets[i]
        @particles.vertices[nextParticle++] = bullet.interpolatedPosition(time)

    # Now check if any bullets went away from last tick, we need to remove their particles
    if nextParticle < @allocatedBulletVertices
      for i in [nextParticle..@allocatedBulletVertices]
        @particles.vertices[nextParticle] = @resetVector
    
    # Now store how many particles are non-reset for this frame
    @allocatedBulletVertices = bullets.length
    
    # Finaly, tell the particle system that we've messed with its vertices.
    @particleSystem.geometry.verticesNeedUpdate = true