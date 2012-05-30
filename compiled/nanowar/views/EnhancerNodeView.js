// Generated by CoffeeScript 1.3.3
(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(function(require) {
    var Backbone, EnhancerNodeView;
    Backbone = require('backbone');
    return EnhancerNodeView = (function(_super) {

      __extends(EnhancerNodeView, _super);

      function EnhancerNodeView() {
        return EnhancerNodeView.__super__.constructor.apply(this, arguments);
      }

      EnhancerNodeView.prototype.initialize = function(options) {
        var _this = this;
        this.gameView = options.gameView;
        window.lastCellView = this;
        this.gameView.bind('select', this.render, this);
        this.model.bind('change', this.render, this);
        this.model.bind('affectedCells:add', this.addConnectionTo, this);
        this.model.bind('affectedCells:remove', this.removeConnectionTo, this);
        this.el = document.createElementNS("http://www.w3.org/2000/svg", "use");
        this.el.setAttributeNS("http://www.w3.org/1999/xlink", "href", "#EnhanceNodeIconBlue");
        this.el.setAttribute("transform", "translate(" + (this.model.get('x')) + "," + (this.model.get('y')) + "), scale(.2)");
        this.el.setAttribute("filter", "url(#compShadow)");
        this.gameView.svg.appendChild(this.el);
        this.connections = {};
        _(this.model.affectedCells()).each(function(cell) {
          return _this.addConnectionTo(cell);
        });
        return $(this.el).click(function() {
          return _this.trigger('click');
        });
      };

      EnhancerNodeView.prototype.render = function() {
        return this;
      };

      EnhancerNodeView.prototype.addConnectionTo = function(cell) {
        var cpos, me;
        me = this.model.position();
        cpos = cell.position();
        this.connections[cell.id] = this.gameView.paper.path("M" + me.x + " " + me.y + "L" + cpos.x + " " + cpos.y);
        return console.log("enlarging " + cell.id);
      };

      EnhancerNodeView.prototype.removeConnectionTo = function(cell) {
        this.connections[cell.id] && this.connections[cell.id].remove();
        return delete this.connections[cell.id];
      };

      return EnhancerNodeView;

    })(Backbone.View);
  });

}).call(this);