// Generated by CoffeeScript 1.3.3
(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(function(require) {
    var EntityCollection, IdentifyingCollection, _;
    IdentifyingCollection = require('../helpers/IdentifyingCollection');
    _ = require('underscore');
    return EntityCollection = (function(_super) {

      __extends(EntityCollection, _super);

      function EntityCollection() {
        return EntityCollection.__super__.constructor.apply(this, arguments);
      }

      EntityCollection.prototype.initialize = function(models, options) {
        var _this = this;
        if (!(options && (options.types != null))) {
          throw "Need types";
        }
        this.types = {};
        _(options.types).each(function(klass) {
          return _this.types[klass.getType()] = klass;
        });
        if (!(this.game = options.game)) {
          throw "Need game";
        }
        this.bind('add', function(entity) {
          return _this.trigger('publish', {
            add: entity
          });
        });
        this.bind('update', function(data) {
          var ent;
          if (data.add != null) {
            _this.add(data.add);
          }
          if (data.changedEntityId != null) {
            if (!(ent = _this.get(data.changedEntityId))) {
              throw "Could not find entity with id " + data.changedEntityId;
            }
            return ent.trigger('update', data.changeDelta);
          }
        });
        return this.bind('change', function(entity) {
          var delta;
          if (delta = entity.changedAttributes()) {
            return _this.trigger('publish', {
              changedEntityId: entity.id,
              changeDelta: delta
            });
          }
        });
      };

      EntityCollection.prototype._add = function(entity) {
        var entityObj, klass, typeNames;
        if (_(this.types).any(function(type) {
          return entity instanceof type;
        })) {
          return EntityCollection.__super__._add.call(this, entity);
        } else {
          klass = this.types[entity.type];
          if (!klass) {
            typeNames = _(this.types).map(function(klass, name) {
              return name;
            });
            throw "I dont know what to do with " + (JSON.stringify(entity)) + ". Known types are [" + (typeNames.join(', ')) + "]";
          }
          entity.game = this.game;
          entityObj = new klass(entity);
          return EntityCollection.__super__._add.call(this, entityObj);
        }
      };

      return EntityCollection;

    })(IdentifyingCollection);
  });

}).call(this);