var express = require('express');

exports.app = app = express.createServer();

app.use(express.static(__dirname + '/public'));
app.use('/src', express.static(__dirname + '/../compiled'));