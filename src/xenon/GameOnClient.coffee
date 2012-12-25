_                 = require 'underscore'
DyzGameOnClient   = require 'dyz/GameOnClient'
consts = require './index'
ShipFlyControls = require 'xenon/helpers/ShipFlyControls'

module.exports = class GameOnClient extends DyzGameOnClient
  entityTypes: consts.entityTypes

  inputState:
    move: ShipFlyControls.initialState
    orientation:
      x: 0
      y: 0
      z: 0 # unused
      w: 1 # unused


  sendClientInput: ->
    @trigger 'read-controls'
    @trigger 'publish', ticks: @ticks, commands: @commandQueue, inputState: @inputState
    @commandQueue = []