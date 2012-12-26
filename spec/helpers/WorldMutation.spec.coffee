WorldMutation = require('dyz/helpers/WorldMutation')
World = require('dyz/World')
Entity = require('dyz/Entity')

class MyEntity extends Entity
  attributeSpecs:
    strength: 0

  hello: ->
    'world'

describe 'WorldMutation', ->
  describe 'JSON', ->
    it 'records attribute changes', ->
      world = new World MyEntity: MyEntity
      anotherWorld = new World MyEntity: MyEntity
      
      baseMutation = world.mutate ->
        ent = world.spawn 'MyEntity'
        ent.set strength: 9001

      reconstructed = WorldMutation.fromAsJSON(world, JSON.parse(JSON.stringify(baseMutation.asJSON())))
      anotherWorld.applyMutation(reconstructed)

      expect(anotherWorld.entities[0].get('strength')).toBe 9001

    it 'drops the annotations', ->
      world = new World {}
      m = new WorldMutation world, [["changed","Player_1$name","Jack",{"id":"Player_1","attr":"name"}]]
      expect(typeof m.asJSON()[0][3]).toBe 'undefined'
    

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
      expect(bin_part instanceof ArrayBuffer).toBe true
      json_part = JSON.parse(JSON.stringify(c[1]))
      
      reconstructed = WorldMutation.fromBinaryComponents(world, bin_part, json_part)
      console.log reconstructed
      anotherWorld.applyMutation(reconstructed)

      expect(anotherWorld.entities[0].get('strength')).toBe 9001
