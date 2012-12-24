Entity = require('dyz/Entity')
Object3D = require('./mixins/Object3D')

module.exports = class Station extends Entity
  mixins: [Object3D]

  attributeSpecs:
    name:   'Home base'
    
    health: 40000

  update: (playerInput) ->