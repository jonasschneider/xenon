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

  asJSON: ->
    @changes

  # BINARY
  # Only mutations of type 'changed' get recorded.
  # Binary format: sequential recordds, 8 bytes per record.
  # 
  #   ---------------------------------------
  #   |  0  |  1    2   3  |  4   5   6   7 |
  #   ---|-----|--------------|--------------
  #      |     |              |
  #      |     |              \- X: Value
  #      |     |
  #      |     \- Uint24: Key
  #      |
  #      \- Uint8: Record Type.
  #                0 = Reserved,
  #                1 = Change Attribute, X=Int32
  #                2 = Change Attribute, X=Float32
  #                3 = Apply Aside Change,
  #                else reserved
  # 
  # Key is only 20 bits (see WorldState), so the 4 high bits are always zero.
  # If Record Type is 2, pop the next change from the aside array and apply it.
  #

  getBinaryComponents: ->
    changes = @getChanges()
    #console.log changes
    return [new ArrayBuffer(0), []] if changes.length == 0
    buffer = new ArrayBuffer(changes.length*8)
    aside = []
    offset = 0
    view = new DataView(buffer)

    changes.forEach (change) =>
      if change[0] is 'changed' && typeof change[2] == 'number'
        key = change[1]
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
        aside.push change
        type = 3
        key = val = 0

      view.setUint32  offset,  (type << 24) | key # spare the masking
      offset += 8
    
    [buffer, aside]

  @fromBinaryComponents: (buffer, aside) ->
    throw new TypeError() unless buffer instanceof ArrayBuffer
    
    changes = []
    offset = 0
    view = new DataView(buffer)

    while(buffer.byteLength > offset)
      type = view.getUint8 offset
      key = view.getUint32(offset) & ((1<<21)-1)
      
      if type is 1 or type is 2
        if type is 1
          # int
          val = view.getInt32 offset + 4
        else
          # float
          val = view.getFloat32 offset + 4

        changes.push ["changed", key, val]

      else if type is 3
        changes.push aside.shift()
      else
        throw "unknown type #{type}"

      offset += 8
    
    new WorldStateMutation(changes)