World = require('dyz/World')
Entity = require('dyz/Entity')

class EntWithAttrs extends Entity
  attributeSpecs:
    strength: 0

PositionEntMixin =
  attributeSpecs:
    mixinAttr: 0

  methods:
    isAwesome: ->
      @get('ownAttr') == 1

class EntWithMixin extends Entity
  mixins: [PositionEntMixin]

  attributeSpecs:
    ownAttr: 0

class EntWithoutAttrs extends Entity

describe 'Entity', ->
  beforeEach ->
    @world = new World EntWithAttrs: EntWithAttrs, EntWithoutAttrs: EntWithoutAttrs, EntWithMixin: EntWithMixin
  
  it 'throws when setting undeclared attributes', ->
    ent = @world.spawn 'EntWithAttrs', strength: 10
    ent.set strength: 5

    expect ->
      ent.set lolz: 'ohai'
    .toThrow()

  it 'allows entities without attributes', ->
    fleet = @world.spawn 'EntWithoutAttrs'
    
    expect ->
      fleet.set strength: 5
    .toThrow()

  describe '#attributes', ->
    it 'collects the attributes and returns them', ->
      fleet = @world.spawn 'EntWithAttrs'
      
      expect(JSON.stringify fleet.attributes()).toBe '{"strength":0,"dead":false}'
  
  describe 'mixins', ->
    it 'gets the attributes provided by the mixin', ->
      ent = @world.spawn 'EntWithMixin'
      ent.set ownAttr: 1
      ent.set mixinAttr: 1

      expect(ent.isAwesome()).toBe true