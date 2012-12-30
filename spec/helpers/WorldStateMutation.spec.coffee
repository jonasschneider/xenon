WorldStateMutation = require('dyz/helpers/WorldStateMutation')
World = require('dyz/World')
Entity = require('dyz/Entity')

class MyEntity extends Entity
  attributeSpecs:
    strength: 0

  hello: ->
    'world'

describe 'WorldStateMutation', ->
  describe 'JSON', ->
    it 'records attribute changes', ->
      world = new World MyEntity: MyEntity
      anotherWorld = new World MyEntity: MyEntity
      
      baseMutation = world.mutate ->
        ent = world.spawn 'MyEntity'
        ent.set strength: 9001

      reconstructed = WorldStateMutation.fromAsJSON(JSON.parse(JSON.stringify(baseMutation.asJSON())))
      anotherWorld.applyMutation(reconstructed)

      expect(anotherWorld.entities[0].get('strength')).toBe 9001

  describe 'binary', ->
    it 'records an empty change', ->
      world = new World MyEntity: MyEntity
      anotherWorld = new World MyEntity: MyEntity
      
      baseMutation = world.mutate ->

      c = baseMutation.getBinaryComponents()
    
    it 'records attribute changes', ->
      world = new World MyEntity: MyEntity
      anotherWorld = new World MyEntity: MyEntity
      
      baseMutation = world.mutate ->
        ent = world.spawn 'MyEntity'
        ent.set strength: 9001

      c = baseMutation.getBinaryComponents()
      bin_part = c[0] # how to simulate a binary transfer?
      #expect(bin_part instanceof ArrayBuffer).toBe true
      json_part = JSON.parse(JSON.stringify(c[1]))
      
      reconstructed = WorldStateMutation.fromBinaryComponents(bin_part, json_part)
      console.log reconstructed
      anotherWorld.applyMutation(reconstructed)

      expect(anotherWorld.entities[0].get('strength')).toBe 9001

    it 'deduplicates', ->
      world = new World MyEntity: MyEntity
      anotherWorld = new World MyEntity: MyEntity
      
      ent = world.spawn 'MyEntity'
      
      referenceMutation = world.mutate ->
        ent.set strength: 180
      
      baseMutation = world.mutate ->
        ent.set strength: 9000
        ent.set strength: 9001

      bin_should = referenceMutation.getBinaryComponents()[0]
      bin_is = baseMutation.getBinaryComponents()[0]
      expect(bin_is.byteLength).toBe bin_should.byteLength