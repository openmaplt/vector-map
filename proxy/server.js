const logger = require("./logger");
const fs = require('fs');
const express = require('express');
const app = express();
const path = require('path');
const morgan = require("morgan");

var public = process.env.PUBLIC_PATH || path.join(__dirname, 'public');
var tilesUrl = process.env.TILES_URL || 'http://localhost:8080/all/{z}/{x}/{y}.pbf';

app.use(morgan(':remote-addr - :method :url :status :response-time ms - :res[content-length]'));

// allow CORS
app.all('*', (req, res, next) => {
  res.header('Access-Control-Allow-Origin', '*');
  res.header('Access-Control-Allow-Methods', 'GET,HEAD');
  res.header('Access-Control-Allow-Headers', 'X-Requested-With,Content-Type,Authorization');
  next();
});

// rewrite source path to local webservice
app.use('/styles/*\.json', function (req, res, next) {
  var filename = path.join(public, req.baseUrl);
  var style = JSON.parse(fs.readFileSync(filename, 'utf8'));
  if ('sources' in style) {
    for (var key in style.sources) {
      var source = style.sources[key];
      if (source.type != 'vector') {
        continue;
      }
      if (!('tiles' in source)) {
        return;
      }
      source.tiles = [tilesUrl];
    };
  }
  res.json(style).end();
});

// serve static files
app.use(express.static(public));
app.use('/', function (req, res) {
  res.sendFile(path.join(public, 'index.html'));
});

var server = app.listen(process.env.PORT || 8000, () => {
  logger.info(`listening on: ${server.address().port}`)
});

process.on('SIGINT', function () {
  server.close();
  process.exit();
});

