Entity = require('dyz/Entity')
BallisticObject3D = require('./mixins/BallisticObject3D')
THREE = require('three')

module.exports = class Bullet extends Entity
  mixins: [BallisticObject3D]
  
  initialize: ->
    @fuel = 100

  attributeSpecs:
    # position_{x,y,z} is the launch position
    health: 100
    launchTime: 0

    #damage: 0
  interpolatedPosition: (time) ->
    startPos = new THREE.Vector3 @get('position_x'), @get('position_y'), @get('position_z')
    trajectory = new THREE.Vector3 @get('velocity_x'), @get('velocity_y'), @get('velocity_z')
    fraction = (time - @collection.tickStartedAt) / @collection.tickLength
    trajectory.multiplyScalar @ticks()-@get('launchTime') + fraction

    startPos.addSelf(trajectory)

  hit: (ship) ->
    shippos = new THREE.Vector3 ship.get('position_x'), ship.get('position_y'), ship.get('position_z')
    #ship.set position_x: ship.get('position_x')+500
    for target in @collection.getEntitiesOfType('Ship')
      targetpos = new THREE.Vector3 target.get('position_x'), target.get('position_y'), target.get('position_z')
      targetpos.subSelf(shippos)

      if(targetpos.length()) < 500
        target.message 'explode'
        target.set color: 0x00FF00
    
    @set dead: true

  update: ->
    pos = @interpolatedPosition(@collection.tickStartedAt)
    for ship in @collection.getEntitiesOfType('Ship')
      shippos = new THREE.Vector3 ship.get('position_x'), ship.get('position_y'), ship.get('position_z')
      shippos.subSelf(pos)

      if(shippos.length()) < 200
        @hit(ship)
        break

    @fuel -= 1
    if @get('health') <= 0 || @fuel <= 0
      @set dead: true