Backbone = require('backbone')
_                     = require 'underscore'
WorldState = require 'dyz/helpers/WorldState'
LIMIT = Math.pow(2,11)-1
module.exports = class World
  constructor: (types) ->
    throw "Need types" unless types
    
    @ticks = 0

    @types = {}
    @nextEntityIds = {}
    @nextNetworkId = 1
    @state = new WorldState

    @state.registerEvent 'remove', _(@remove).bind(this)
    @state.registerEvent 'spawn', _(@spawn).bind(this)
    @state.registerEvent 'entmsg', _(@sendEntityMessage).bind(this)
    @state.onChange = _(@_touchChangedEntity).bind(this)

    @entities = []
    @entitiesById = {}

    _(types).each (klass, name) =>
      @types[name] = klass
      @nextEntityIds[name] = 1

  enableStrictMode: ->
    @state.strictMode = true

  #
  # ENTITY HOUSEKEEPING
  # 

  spawn: (type, attributes) ->
    klass = @types[type] or throw "unknown entity type #{type}"
    attributes or (attributes = {})

    if attributes.id
      newId = attributes.id
      delete attributes.id
    else
      newId = @nextNetworkId++
      
      if newId > LIMIT
        # search for a new ID, TODO: optimize?
        newId = 1
        newId++ while @entitiesById[newId] 
        throw 'entitiy limit reached' if newId > LIMIT
    
    if !newId
      console.trace()
      raise 'dat fail'
    attributes.humanId = type + '_' + @nextEntityIds[type]++

    ent = new klass this, newId
    ent.entityTypeName = type
    
    throw "id #{newId} is in use" if @entitiesById[newId]
    @entities.push ent
    @entitiesById[newId] = ent

    @state.recordEvent 'spawn', type, {id: newId}
    
    ent._initialize()
    ent.set attributes

    @trigger 'spawn', ent

    ent

  get: (id) ->
    @entitiesById[id]

  remove: (entOrId) ->
    if entOrId.id?
      id = entOrId.id
    else
      id = entOrId

    ent = @get(id)
    ent.trigger 'remove'

    @state.recordEvent 'remove', id
    

    for attr in _(ent.attributeSpecs).keys()
      k = @_generateAttrKeyFromAttrName(id, attr)
      @state.unset k

    idx = @entities.indexOf(ent)
    @entities.splice(idx, 1)
    delete @entitiesById[ent.id]
    null

  getEntitiesOfType: (typename) ->
    klass = @types[typename]
    results = []
    for ent in @entities
      results.push ent if ent instanceof klass
    results

  #
  # ENTITY ATTRIBUTES
  #

  getEntityAttribute: (entId, attrId) ->
    throw "on get: unknown ent #{entId}" unless @get(entId)
    key = @_generateAttrKey(entId, attrId)
    @state.get key

  setEntityAttribute: (entId, attrId, value) ->
    ent = @get(entId)
    unless ent
      console.trace()
      throw "on set: unknown ent #{entId}" 
    key = @_generateAttrKey(entId, attrId)
    @state.set key, value
    ent.trigger 'change'
    value

  _generateAttrKey: (entId, attrId) ->
    (entId << 10) | attrId

  _generateAttrKeyFromAttrName: (entId, attr) ->
    @_generateAttrKey entId, @get(entId).attributeIndex[attr]

  _parseAttrKey: (key) ->
    [key >> 10, key & (1<<10)-1 ]

  _touchChangedEntity: (key) ->
    if [entId, attr] = @_parseAttrKey(key)
      @get(entId).trigger 'change'



  sendEntityMessage: (entId, name, data) ->
    if data && data.toJSON
      payload = data.toJSON()
    else
      payload = data
    @state.recordEvent 'entmsg', entId, name, payload
    if data && data.entId
      arg = @get(data.entId)
    else
      arg = data
    @get(entId).trigger name, arg

  # apply the mutation, and then set an interpolation checkpoint.
  # this means that state values that have not been changed since the
  # last checkpoint will not be interpolated anymore. this is the case
  # after a movement has stopped.
  # see WorldState.spec
  applyMutationWithInterpolationCheckpoint: (mutation) ->
    @applyMutation(mutation)
    @state.interpolationCheckpoint()

  #
  # MUTATIONS & SNAPSHOTS
  #

  mutate: (mutator) ->
    @state.mutate mutator

  applyMutation: (mutation) ->
    @state.applyMutation mutation

  snapshotAttributes: ->
    @state.makeSnapshot()

  applyAttributeSnapshot: (snapshot) ->
    # TODO: notify changed world
    @state.applySnapshot(snapshot)

  snapshotFull: ->
    for ent in @entities
      attr = ent.attributes()
      attr.id = ent.id
      [ent.entityTypeName, attr]

  applyFullSnapshot: (fullSnapshot) ->
    for [type, attributes] in fullSnapshot
      @spawn type, attributes

_.extend(World.prototype, Backbone.Events)

methods = ['forEach', 'each', 'map', 'reduce', 'reduceRight', 'find', 'detect',
  'filter', 'select', 'reject', 'every', 'all', 'some', 'any', 'include',
  'contains', 'invoke', 'max', 'min', 'sortBy', 'sortedIndex', 'toArray', 'size',
  'first', 'rest', 'last', 'without', 'indexOf', 'lastIndexOf', 'isEmpty', 'groupBy'];

# Mix in each Underscore method as a proxy
_.each methods, (method) ->
  World.prototype[method] = ->
    _[method].apply(_, [this.entities].concat(_.toArray(arguments)))