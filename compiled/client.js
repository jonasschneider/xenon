// Generated by CoffeeScript 1.3.3
(function() {

  define(function(require) {
    var app, appview;
    console.log('hai');
    console.log(require('jquery'));
    require('processing-1.3.0');
    app = require('nanowar/models/App');
    appview = require('nanowar/views/AppView');
    window.App = new app;
    return window.AppView = new appview({
      model: window.App
    });
  });

}).call(this);