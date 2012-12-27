_              = require 'underscore'
GameOnClient   = require 'xenon/GameOnClient'
THREE = require 'three'
module.exports = class CreepAI
  constructor: (ship) ->
    @ship = ship
    @world = ship.collection

    @target = @world.getEntitiesOfType('Planet')[0]

  getInput: ->
    x = _(GameOnClient.initialInputState).clone()

    pos = new THREE.Vector3 @ship.get('position_x'), @ship.get('position_y'), @ship.get('position_z')
    #console.log pos
    direction = new THREE.Vector3 @target.get('position_x'), @target.get('position_y'), @target.get('position_z')
    direction.subSelf(pos)
    direction.normalize()

    x["orientation_x"] = direction.x
    x["orientation_y"] = direction.y
    x["orientation_z"] = direction.z
    x["move_forward"] = 1
    

    if @world.ticks % 100 > 20
      #x["move_right"] = 1
      #x["move"]["left"] = 0
    else
      x["attack"] = 1
      #x["move"]["right"] = 0
      #x["move_left"] = 1
      #x["move"]["forward"] = 1
      #x["move"]["back"] = 1

    x