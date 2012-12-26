_ = require 'underscore'

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

  _changeWithoutAnnotation: (change) ->
    if change[0] == 'changed' && change.length > 3
      # remove the annotation
      change = _(change).clone()
      change.pop()
    change
  
  asJSON: ->
    memo = []
    @changes.forEach (change) =>
      memo.push @_changeWithoutAnnotation(change)
    memo

  # BINARY
  # Only mutations of type 'changed' get recorded.
  # Binary format: sequential recordds, 8 bytes per record.
  # 
  #   ----------------------------------------
  #   |  0  |  1  |  2   3  |  4   5   6   7 |
  #   ---|-----|-----|---------|--------------
  #      |     |     |         |
  #      |     |     |         \- X: Value
  #      |     |     |
  #      |     |     \- Uint16: Entity ID
  #      |     |
  #      |     \- Uint8: Attribute ID 
  #      |
  #      \- Uint8: Record Type.
  #                0 = Reserved,
  #                1 = Change Attribute, X=Int32
  #                2 = Change Attribute, X=Float32
  #                3 = Apply Aside Change,
  #                else reserved
  # 
  # If Record Type is 2, pop the next change from the aside array and apply it.
  #

  getBinaryComponents: ->
    changes = @getChanges()
    console.log changes
    buffer = new ArrayBuffer(changes.length*8)
    aside = []
    offset = 0
    view = new DataView(buffer)

    changes.forEach (change) =>
      if change[0] is 'changed' && typeof change[2] == 'number'
        attr = change[3].attr
        ent = change[3].id
        val = change[2]

        if val % 1 == 0
          # int
          type = 1
          view.setInt32 offset + 4, val
        else
          # float
          type = 2
          view.setFloat32 offset + 4, val

      else
        aside.push(@_changeWithoutAnnotation(change))
        type = 3
        attr = ent = 0

      view.setUint32  offset,  (type << 24) + (attr << 16) + ent
      offset += 8
    
    [buffer, aside]

  @fromBinaryComponents: (world, buffer, aside) ->
    throw new TypeError() unless buffer instanceof ArrayBuffer
    console.log [buffer, aside]
    
    changes = []
    offset = 0
    view = new DataView(buffer)

    while(buffer.byteLength > offset)
      type = view.getUint8 offset
      attr = view.getUint8 offset + 1
      ent = view.getUint16 offset + 2

      if type is 1 or type is 2
        if type is 1
          # int
          val = view.getInt32 offset + 4
        else
          # float
          val = view.getFloat32 offset + 4

        changes.push ["changed", ent.toString()+"$"+attr.toString(), val]

      else if type is 3
        changes.push aside.shift()
      else
        throw "unknown type #{type}"

      offset += 8
    
    new WorldMutation(world, changes)