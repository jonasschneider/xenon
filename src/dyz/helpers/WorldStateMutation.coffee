_ = require 'underscore'

module.exports = class WorldStateMutation
  @parse: (stuff) ->
    if stuff instanceof WorldStateMutation
      stuff
    else
      # assume it's coming from asJSON()
      @fromAsJSON(stuff)

  @fromAsJSON: (obj) ->
    new WorldStateMutation(obj)
  
  constructor: (changes) ->
    @changes = changes || []

  getChanges: ->
    @changes

  getDeduplicatedChanges: ->
    return [] if @changes.length == 0
    deduplicated = []
    changedKeys = []
    for i in [@changes.length-1..0]
      c = @changes[i]
      unless c[0] == 'changed'
        deduplicated.unshift c 
      else
        if changedKeys.indexOf(c[1]) == -1
          changedKeys.push c[1]
          deduplicated.unshift c
    
    deduplicated

  asJSON: ->
    @getDeduplicatedChanges()