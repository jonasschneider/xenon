define (require) ->
  RelationalModel = require('nanowar/helpers/RelationalModel')
  _ = require('underscore')
  Backbone = require('backbone')

  class Entity
    constructor: (collection, id) ->
      throw 'Entity constructor needs collection' unless collection
      throw 'Entity constructor needs id' unless id

      @collection = collection
      @id = id

    _initialize: ->
      @set @attributeSpecs, silent: true
      @initialize() if @initialize

    ticks: ->
      @collection.ticks()

    get: (attr) ->
      unless attr in _(@attributeSpecs).keys()
        console.trace()
        throw "attempted to get undeclared attribute #{attr}" 

      @collection.getEntityAttribute(@id, attr)

    set: (attrs, options) ->
      # FIXME: this is from RelationalModel
      #attrs = @_dereferenceRelations(attrs)


      options or (options = {})
      return this  unless attrs

      return false  if not options.silent and @validate and not @_performValidation(attrs, options)
      @id = attrs[@idAttribute]  if @idAttribute of attrs
      alreadyChanging = @_changing
      @_changing = true
      for attr of attrs
        throw "attempted to set undeclared attribute #{attr}" unless attr in _(@attributeSpecs).keys()
        val = attrs[attr]
        unless _.isEqual(@get(attr), val)
          @collection.setEntityAttribute(@id, attr, val, options.silent)

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
      data[idKey] = entity.id
      @set data

    getRelation: (relationName) ->
      idKey = relationName+'_id'
      if id = @get(idKey)
        @collection.get(id)
      else
        undefined

    toString: ->
      @id || super

  _.extend(Entity.prototype, Backbone.Events)
  return Entity