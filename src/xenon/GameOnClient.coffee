_                 = require 'underscore'
DyzGameOnClient   = require 'dyz/GameOnClient'
consts = require './index'
ShipFlyControls = require 'xenon/helpers/ShipFlyControls'

module.exports = class GameOnClient extends DyzGameOnClient
  entityTypes: consts.entityTypes

  @initialInputState: ShipFlyControls.initialState
  
  inputState: _(ShipFlyControls.initialState).clone()

  sendClientInput: ->
    @trigger 'read-controls'
    #console.log JSON.stringify(@inputState)
    @trigger 'publish', ticks: @ticks, commands: @commandQueue, inputState: @inputState
    @commandQueue = []