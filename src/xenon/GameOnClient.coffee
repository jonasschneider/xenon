_                 = require 'underscore'
DyzGameOnClient   = require 'dyz/GameOnClient'
consts = require './index'

module.exports = class GameOnClient extends DyzGameOnClient
  entityTypes: consts.entityTypes

  inputState:
    move:
      up: 0
      down: 0
      left: 0
      right: 0
      forward: 0
      back: 0
      pitchUp: 0
      pitchDown: 0
      yawLeft: 0
      yawRight: 0
      rollLeft: 0
      rollRight: 0
    orientation:
      x: 0
      y: 0
      z: 0 # unused
      w: 1 # unused


  sendClientInput: ->
    @trigger 'read-controls'
    @trigger 'publish', ticks: @ticks, commands: @commandQueue, inputState: @inputState
    @commandQueue = []