Entity = require('dyz/Entity')
Object3D = require('./mixins/Object3D')

module.exports = class Planet extends Entity
  mixins: [Object3D]

  attributeSpecs:
    name:   'Earth'
    
    #xenonAvailable: 40000
  
  update: (playerInput) ->