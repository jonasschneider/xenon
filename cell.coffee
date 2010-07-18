Log: NanoWar.Log

class NanoWar.Cell
  constructor: (x, y, size, owner) -> 
    @x: x
    @y: y
    @size: size
    @owner: owner
    
    @game: null
    @id: NanoWar.uniqueIdCount++
    
    @last_absolute_units: 0
    @last_absolute_ticks: 0
  
  set_owner: (new_owner) ->
    @owner: new_owner
    if new_owner && new_owner.color
      @elem.setAttribute("fill", new_owner.color)
      @elem.removeClass("neutral")
    else
      @elem.setAttribute("fill", null)
      @elem.addClass("neutral")
  
  handle_incoming_fleet: (fleet) ->
    if fleet.owner == @owner # friendly fleet
      Log "Friendly fleet of $fleet.strength arrived at $@id"
      @change_units(fleet.strength)
    else # hostile fleet
      Log "Hostile fleet of $fleet.strength arrived at $@id"
      @change_units(-fleet.strength)
      if @units() == 0
        @owner: null
        Log "$@id changed to neutral"
      else if @units() < 0
        @set_owner fleet.owner
        @set_units(-@units())
        Log "$@id overtaken by $fleet.owner.name"
    
  nearest_border: (pos) ->
    dx = pos.x - @x
    dy = @y - pos.y
    
    alpha = Math.atan(dy/dx)
    
    x = Math.cos(alpha)*@size
    y = Math.sin(alpha)*@size
    
    # trial and error
    if(@x > pos.x || @y < pos.y)
      x = x * -1 
      y = y * -1
      
    if(@x <= pos.x && @y < pos.y)
      x = x * -1 
      y = y * -1
    
    return { x: @x+x, y: @y-y}
  
  setup: (game) ->
    @game: game
    
    
    @elem: document.createElementNS( "http://www.w3.org/2000/svg", "circle" )
    @elem.nw_cell: this
    @elem.setAttributes {
      cx: @x
      cy: @y
      r: @size
      "class": "cell"
    }
    
    @set_owner @owner
    
    
    @unit_container: document.createElementNS( "http://www.w3.org/2000/svg", "text" )
    @unit_container.nw_cell: this
    @unit_container.setAttributes {
      x: @x
      y: @y
      transform: "translate(0,5)"
      "class": "cell-data"
    }
    
    @unit_text: document.createTextNode("0")
    @unit_container.appendChild(@unit_text)
    
    
    @game.container[0].appendChild(@elem)
    @game.container[0].appendChild(@unit_container)
  
  draw: ->
    @unit_text.nodeValue: @units()
  
  unit_growth: ->
    return 0 unless @owner # neutral cells don't produce
    Math.floor((@game.ticks - @last_absolute_ticks) / 1000 * @size * 2)
    
  units: ->
    @last_absolute_units + @unit_growth()
    
  set_units: (num) ->
    @last_absolute_units: num
    @last_absolute_ticks: @game.ticks
  
  change_units: (delta) ->
    @set_units @units() + delta