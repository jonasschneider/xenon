Backbone = require 'backbone'
GameNetGraphView = require 'dyz/views/GameNetGraphView'

FlyControls = require 'xenon/helpers/FlyControls'
WorldView = require './WorldView'
_                 = require 'underscore'

requestAnimFrame = (->
  window.requestAnimationFrame or window.webkitRequestAnimationFrame or window.mozRequestAnimationFrame or window.oRequestAnimationFrame or window.msRequestAnimationFrame or (callback) ->
    window.setTimeout callback, 1000 / 60
)()

module.exports = class GameView extends Backbone.View
  initialize: (options)->
    @appView = options.appView
    throw "need app view" unless @appView
    @frames = 0
    
    @container = $('#nanowar')

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

    #@controls = new FlyControls @worldv.camera
    @controls = new FlyControls(new THREE.PerspectiveCamera(40, 1, 1, 1))
    @controls.movementSpeed = 2500
    @controls.rollSpeed = Math.PI / 6
    @controls.autoForward = false
    @controls.dragToLook = true

    @halt = false
    @model.bind 'halt', =>
      @halt = true

    @model.bind 'read-controls', =>
      @model.inputState.move = @controls.moveState
    
    setTimeout =>
      @trigger 'ready'
    ,0

  render: (time) ->
    @frames++
    delta = @clock.getDelta()

    @controls.update delta

    @worldv.render(time)

    #@canvas.getContext("2d").clearRect(0,0,700,500)
    #f.render(time) for f in @fleetvs

    requestAnimFrame _(@render).bind(this) unless @halt

  updateObjects: ->
    console.log 'update call'
    console.log(arguments)
  