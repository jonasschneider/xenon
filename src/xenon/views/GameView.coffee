Backbone = require 'backbone'
GameNetGraphView = require 'dyz/views/GameNetGraphView'

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

    ng = new GameNetGraphView model: @model, gameView: this
    @container.append ng.render().el

    @worldv = new WorldView model: @model.world
    @container.append @worldv.el

    requestAnimFrame _(@render).bind(this)
    
    setTimeout =>
      @trigger 'ready'
    ,0

  render: (time) ->
    @frames++

    @worldv.render(time)

    #@canvas.getContext("2d").clearRect(0,0,700,500)
    #f.render(time) for f in @fleetvs

    requestAnimFrame _(@render).bind(this)

  updateObjects: ->
    console.log 'update call'
    console.log(arguments)
  