module.exports = class WorldMutation
  @parse: (world, stuff) ->
    if stuff instanceof WorldMutation
      stuff
    else
      console.log "deserializing #{stuff}"
      # assume it's coming from asJSON()
      @fromAsJSON(world, stuff)

  @fromAsJSON: (world, obj) ->
    new WorldMutation(world, obj)
  
  constructor: (world, changes) ->
    @world = world
    @changes = changes || []

  getChanges: ->
    @changes

  asJSON: ->
    @changes

  # BINARY

  getBinaryComponents: ->
    [new ArrayBuffer(1), @asJSON()]

  @fromBinaryComponents: (world, bin, json) ->
    new WorldMutation(world, json)