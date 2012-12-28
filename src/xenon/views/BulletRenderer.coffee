THREE = require('three')

module.exports = class BulletRenderer
  resetVector: new THREE.Vector3 -1000000, 0,0
  allocateCount: 2000

  constructor: (bullets, world) ->
    @bullets = bullets
    @world = world
    
    @particles = new THREE.Geometry()
    pMaterial = new THREE.ParticleBasicMaterial
      color: 0xFFFFFF
      size: 100
      map: THREE.ImageUtils.loadTexture "/images/particles/ball.png"
      blending: THREE.AdditiveBlending,
      transparent: true
      opacity: 0.7

    @particles.vertices.push @resetVector for i in [0..@allocateCount-1]
    @particleSystem = particleSystem = new THREE.ParticleSystem(@particles, pMaterial)
    #particleSystem.sortParticles = true

    @allocatedBulletVertices = 0

  update: (time) ->
    # If we are over the limit, just don't display any further bullets
    len = @bullets.length
    if @bullets.length > @particles.vertices.length
      console.error 'not enough particles allocated for bullet display'
      len = @particles.vertices.length

    # This stores the next available particle a bullet could use
    nextParticle = 0

    # Go through each bullet from the end of the list so we can safely delete orphans
    for i in [len-1..0]
      if (b=@bullets[i]) && @world.entitiesById[b.id]
        # Yep, the bullet is actually still there, set a particle to its position
        @particles.vertices[nextParticle++] = b.interpolatedPosition(time)
      else
        @bullets.splice(i,1)

    # Now check if any bullets went away from last tick, we need to remove their particles
    if nextParticle < @allocatedBulletVertices
      for i in [nextParticle..@allocatedBulletVertices]
        @particles.vertices[nextParticle] = @resetVector
    
    # Now store how many particles are non-reset for this frame
    @allocatedBulletVertices = @bullets.length
    
    # Finaly, tell the particle system that we've messed with its vertices.
    @particleSystem.geometry.verticesNeedUpdate = true