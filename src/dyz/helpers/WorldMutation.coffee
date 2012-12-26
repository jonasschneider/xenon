module.exports = class WorldMutation
  @parse: (world, stuff) ->
    if stuff instanceof WorldMutation
      stuff
    else
      # assume it's coming from asJSON()
      new WorldMutation(world, stuff)
  
  constructor: (world, changes) ->
    @world = world
    @changes = changes || []

  getChanges: ->
    @changes
  
  record: ->
    console.log arguments

  asJSON: ->
    @changes