_              = require 'underscore'
GameOnClient   = require 'xenon/GameOnClient'

module.exports = class CreepAI
  constructor: (ship) ->
    @ship = ship
    @world = ship.collection

  getInput: ->
    x = _(GameOnClient.initialInputState).clone()

    if @world.ticks % 100 > 20
      x["move_right"] = 1
      #x["move"]["left"] = 0
    else
      #x["move"]["right"] = 0
      x["move_left"] = 1
      #x["move"]["forward"] = 1
      #x["move"]["back"] = 1

    x