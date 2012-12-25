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
    
    @container = $('#nanowar')

    @model.world.bind 'spawn', (e) =>
      return unless e.entityTypeName == 'Player'
      e.bind 'change', =>
        if @client.localPlayerId == e.get('clientId')
          @localPlayer = e


    $("#move-btn").click =>
      console.warn "click occured at #{@model.ticks}"
      @model.queueClientCommand 'moveStuff'

    $("#shoot-btn").click =>
      console.warn "click occured at #{@model.ticks}"
      @model.queueClientCommand 'shootStuff'

    ng = new GameNetGraphView model: @model, gameView: this
    @container.append ng.render().el

    @worldv = new WorldView model: @model.world
    @container.append @worldv.el

    requestAnimFrame _(@render).bind(this)

    @clock = new THREE.Clock()

    @controls = new ShipFlyControls @worldv.camera
    #@controls = new FlyControls(new THREE.PerspectiveCamera(40, 1, 1, 1))
    @controls.movementSpeed = 2500
    @controls.rollSpeed = Math.PI / 6
    @controls.autoForward = false
    @controls.dragToLook = true

    @halt = false
    @model.bind 'halt', =>
      @halt = true

    @model.bind 'read-controls', =>
      @model.inputState.move = @controls.moveState
      @model.inputState.orientation =
        x: @worldv.camera.quaternion.x
        y: @worldv.camera.quaternion.y
        z: @worldv.camera.quaternion.z
        w: @worldv.camera.quaternion.w
    
    setTimeout =>
      @trigger 'ready'
    ,0

  render: (time) ->
    @frames++
    delta = @clock.getDelta()

    @controls.update delta

    
    if @localPlayer
      if ship = @localPlayer.getRelation('boarded_ship')
        ship.applyInterpolatedPosition(@worldv.camera, time)
        @worldv.camera.translateZ(400)

    @worldv.render(time)
    #@canvas.getContext("2d").clearRect(0,0,700,500)
    #f.render(time) for f in @fleetvs

    requestAnimFrame _(@render).bind(this) unless @halt

  updateObjects: ->
    console.log 'update call'
    console.log(arguments)
  