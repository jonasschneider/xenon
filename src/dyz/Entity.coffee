_ = require('underscore')
Backbone = require('backbone')

module.exports = class Entity
  constructor: (collection, id) ->
    throw 'Entity constructor needs collection' unless collection
    throw 'Entity constructor needs id' unless id

    @collection = collection
    @id = id

    @attributeSpecs ||= {}
    @attributeSpecs.dead = false
    @attributeSpecs.humanId = ''
    @mixins ||= []
    _(@mixins).each (mixin) =>
      _.extend @attributeSpecs, mixin.attributeSpecs
      _.extend this, mixin.methods
    
    i = 1
    @attributeIndex = {}
    _(@attributeSpecs).each (v, k) =>
      @attributeIndex[k] = i++

  _initialize: ->
    @set @attributeSpecs
    @initialize() if @initialize

  ticks: ->
    @collection.ticks

  get: (attr) ->
    v = @collection.getEntityAttribute(@id, @attributeIndex[attr])
    if v?
      v
    else
      unless attr in _(@attributeSpecs).keys()
        throw "attempted to get undeclared attribute #{attr}" 

  set: (attrs, options) ->
    options or (options = {})
    return this  unless attrs

    #return false  if not options.silent and @validate and not @_performValidation(attrs, options)
    @id = attrs[@idAttribute]  if @idAttribute of attrs
    alreadyChanging = @_changing
    @_changing = true

    for attr of attrs
      unless attr in _(@attributeSpecs).keys()
        console.trace()
        throw "attempted to set undeclared attribute #{attr}" 
      val = attrs[attr]
      unless _.isEqual(@get(attr), val)
        @collection.setEntityAttribute(@id, @attributeIndex[attr], val)

        @_changed = true
        @trigger "change:" + attr, this, val, options  unless options.silent
    
    @change options  if not alreadyChanging and not options.silent and @_changed
    @_changing = false
    this

  change: (options) ->
    this.trigger('change', this, options)
    this._previousAttributes = _.clone(this.attributes)
    this._changed = false

  setRelation: (relationName, entity) ->
    idKey = relationName+'_id'
    data = {}
    if !entity?
      data[idKey] = null
    else if entity.entId? #serialized entity
      data[idKey] = entity.entId
    else
      data[idKey] = entity.id
    @set data

  getRelation: (relationName) ->
    idKey = relationName+'_id'
    if id = @get(idKey)
      @collection.get(id)
    else
      null

  toString: ->
    @id || super

  toJSON: ->
    {entId: @id}

  message: (name, data) ->
    @collection.sendEntityMessage(@id, name, data)

  interpolate: (attr, time) ->
    #console.log time, @collection.tickStartedAt, @collection.tickLength
    fraction = (time - @collection.tickStartedAt) / @collection.tickLength
    key = @collection._generateAttrKey(@id, @attributeIndex[attr])
    @collection.state.interpolate key, fraction
    #console.log(fraction)

  attributes: ->
    x = {}
    for own attr of @attributeSpecs
      x[attr] = @get attr
    x

_.extend(Entity.prototype, Backbone.Events)