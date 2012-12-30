Backbone = require 'backbone'
GameNetGraphView = require 'dyz/views/GameNetGraphView'
THREE = require('three')

ShipFlyControls = require 'xenon/helpers/ShipFlyControls'
WorldView = require './WorldView'
_                 = require 'underscore'
$ = require('jquery')

requestAnimFrame = (->
  window.requestAnimationFrame or window.webkitRequestAnimationFrame or window.mozRequestAnimationFrame or window.oRequestAnimationFrame or window.msRequestAnimationFrame or (callback) ->
    window.setTimeout callback, 1000 / 60
)()

module.exports = class GameView extends Backbone.View
  initialize: (options)->
    @client = options.client
    throw "need client" unless @client
    @frames = 0
    
    @container = $('#game')

    @model.world.bind 'spawn', (e) =>
      return unless e.entityTypeName == 'Player'
      e.bind 'change', =>
        if @client.localPlayerId == e.get('clientId')
          console.log "gameview got local player", e
          @localPlayer = e

    #$("#move-btn").click =>
    #  console.warn "click occured at #{@model.ticks}"
    #  @model.queueClientCommand 'moveStuff'

    @model.bind 'instrument:mutation', (mut) =>
      console.log "== MUTATION REPORT", mut, JSON.stringify(mut.changes)
      uniq = _(mut.changes).chain().filter((c) -> c[0] == 'changed').map((c) -> c[1]).uniq().value().length
      console.log "#{mut.changes.length} changes to #{uniq} keys, #{JSON.stringify(mut.changes).length} bytes uncompressed JSON"
      i=0
      for change in mut.changes
        continue unless change[0] == 'changed'
        [ent, attr] = @model.world._parseAttrKey(change[1])
        ent = @model.world.get(ent)
        continue unless ent
        name=null
        for n, id of ent.attributeIndex
          name = n if id == attr
        old = ent.get(name)
        val = change[2]
        old = old.toFixed(2) if old.toFixed
        val = val.toFixed(2) if old.toFixed
        #console.log "#{ent.get('humanId')}.#{name}: #{old} -> #{val}"

      console.log 


    ng = new GameNetGraphView model: @model, gameView: this
    @container.append ng.render().el

    @worldv = new WorldView model: @model.world
    @container.append @worldv.el

    requestAnimFrame _(@render).bind(this)

    @clock = new THREE.Clock()

    @controls = new ShipFlyControls @worldv.camera
    #@controls = new ShipFlyControls(new THREE.PerspectiveCamera(40, 1, 1, 1))
    @controls.movementSpeed = 2500
    @controls.rollSpeed = Math.PI / 6
    @controls.autoForward = false
    @controls.dragToLook = true

    @halt = false
    @model.bind 'halt', =>
      @halt = true

    @model.bind 'read-controls', =>
      @model.inputState = _(@controls.moveState).clone()
      @model.inputState["orientation_x"] = @worldv.camera.quaternion.x
      @model.inputState["orientation_y"] = @worldv.camera.quaternion.y
      @model.inputState["orientation_z"] = @worldv.camera.quaternion.z
      @model.inputState["orientation_w"] = @worldv.camera.quaternion.w
    
    setTimeout =>
      @trigger 'ready'
    ,0

  render: (time) ->
    @frames++
    delta = @clock.getDelta()
    start = new Date().getTime()
    @controls.update delta
    
    if @localPlayer
      if ship = @localPlayer.getRelation('boarded_ship')
        ship.applyInterpolatedPosition(@worldv.camera, time)
        @worldv.camera.translateZ(400)

    @worldv.render(time, delta)
    #@canvas.getContext("2d").clearRect(0,0,700,500)
    #f.render(time) for f in @fleetvs
    end = new Date().getTime()
    if @frames % 50 == 0
      @trigger 'instrument:render-duration', end-start
    requestAnimFrame _(@render).bind(this) unless @halt

  updateObjects: ->
    console.log 'update call'
    console.log(arguments)
  