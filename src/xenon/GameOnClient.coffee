_                 = require 'underscore'
DyzGameOnClient   = require 'dyz/GameOnClient'
consts = require './index'

module.exports = class GameOnClient extends DyzGameOnClient
  entityTypes: consts.entityTypes