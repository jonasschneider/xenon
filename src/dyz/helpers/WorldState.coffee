Backbone = require('backbone')
_        = require 'underscore'
WorldStateMutation = require 'dyz/helpers/WorldStateMutation'

module.exports = class WorldState
  constructor: ->
    @internalState = {}
    @previousValues = {}
    @events = {}
    @dirty = []
    @previousDirty = []
    @strictMode = false

  registerEvent: (name, cb) ->
    @events[name] = cb

  set: (k, v) ->
    @dirty.push k
    #console.log("change #{k}: #{@internalState[k]} -> #{v}")
    v = Math.round(v) if typeof v == 'number'


    @previousValues[k] = @internalState[k]
    @internalState[k] = v

    @_recordMutation ['changed', k, v]
    
    @onChange(k) if @onChange

  unset: (k) ->
    delete @internalState[k]
    @_recordMutation ['unset', k]

  recordEvent: (name) ->
    throw "unknown event #{name}" unless @events[name]
    args = Array.prototype.splice.call(arguments, 1)
    @_recordMutation ['event', name, args]

  get: (k) ->
    @internalState[k]

  #
  # MUTATIONS
  #

  mutate: (mutator) ->
    throw 'already mutating' if @currentMutations
    @currentMutationChanges = []

    mutator()

    d = @currentMutationChanges
    delete @currentMutationChanges
    d

    new WorldStateMutation(d)

  _recordMutation: (change) ->
    if @currentMutationChanges
      @currentMutationChanges.push change
    else
      throw 'mutation outside mutate() in strict mode' if @strictMode

  applyMutation: (mutation) ->
    m = WorldStateMutation.parse(mutation)
    for change in m.getChanges()
      if change[0] == 'changed'
        @set change[1], change[2]
      if change[0] == 'unset'
        @unset change[1]
      if change[0] == 'event'
        # fire the callback
        @events[change[1]](change[2]...)

  _attributesChangedByMutation: (mutation) ->
    changed = {}
    for change in WorldStateMutation.parse(mutation).getChanges()
      if change[0] == "changed"
        changed[change[1]] = change[2]
    changed

  #
  # SNAPSHOTS
  #

  makeSnapshot: ->
    _.clone(@internalState)

  applySnapshot: (snapshot) ->
    @internalState = snapshot

  interpolationCheckpoint: ->
    stopped_changing = _.difference(@previousDirty, @dirty)
    _(stopped_changing).each (k) =>
      delete @previousValues[k]
    @previousDirty = @dirty
    @dirty = []

  interpolate: (key, fraction) ->
    v1 = @previousValues[key]
    v2 = @internalState[key]
    return v2 unless v1

    v1 + (v2 - v1) * fraction

  extrapolate: (mut1, mut2, n) ->
    delta1 = @_attributesChangedByMutation(mut1)
    delta2 = @_attributesChangedByMutation(mut2)

    for own attr, olderValue of delta1
      continue unless @get attr
      if newerValue = delta2[attr]
        extrapolatedValue = newerValue + (newerValue - olderValue) * n
        
        @set attr, extrapolatedValue