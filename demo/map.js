var cookieName = 'mapData';
var interactiveLayerId = 'label-amenity';
var defaultType = defaultType || 'map';

var mapTypes = {
  map: 'm',
  orto: 'o',
  hybrid: 'h'
};
var mapData = {
  type: 'map',
  zoom: 7,
  lat: 55.19114,
  lng: 23.87100,
  bearing: 0,
  pitch: 0
};

var showAttributes = [
  'name',
  'official_name',
  'opening_hours',
  'website',
  'image'
];

var label = {
  official_name: 'Oficialus pavadinimas'
};

var icons = {
  opening_hours: "glyphicon glyphicon-time",
  website: 'glyphicon glyphicon-globe'
};

var attributeType = {
  name: 'bold',
  website: 'link',
  image: 'image'
};

if (!mapboxgl.supported()) {
  alert('Jūsų naršyklė nepalaiko Mapbox GL. Prašome atsinaujinti naršyklę.');
} else {
  if (hashData = getMapDataFromHashUrl()) {
    $.extend(mapData, hashData);
  }

  if (!hashData && (cookieData = readCookie(cookieName))) {
    $.extend(mapData, cookieData);
  }

  $("button[data-style='" + mapData.type + "']").addClass('active');
  $('#layers').removeClass('hidden');

  changeHashUrl();

  var map = new mapboxgl.Map({
    container: 'map',
    style: 'styles/' + mapData.type + '.json',
    zoom: mapData.zoom,
    minZoom: 7,
    maxZoom: 18,
    center: [mapData.lng, mapData.lat],
    hash: false,
    maxBounds: [20.880, 53.888, 26.862, 56.453],
    bearing: mapData.bearing,
    pitch: mapData.pitch
  })
    .addControl(new mapboxgl.NavigationControl(), 'top-left')
    .addControl(new mapboxgl.GeolocateControl({
      positionOptions: {
        enableHighAccuracy: true
      },
      trackUserLocation: true
    }), 'top-left')
    .on('sourcedata', function () {
      if (map.isStyleLoaded()) {
        poiInteractive();
      }
    })
    .on('moveend', function () {
      setMapData();
      changeHashUrl();
    });
}

$('#layers button').on('click', function (e) {
  if ($(this).hasClass('active')) {
    return false;
  }
  $('#layers button').removeClass('active');
  $(this).addClass('active');

  var selectLayer = $(e.target).data('style');
  map.setStyle('styles/' + selectLayer + '.json');

  mapData.type = selectLayer;
  changeHashUrl(mapData);
});

function changeHashUrl() {
  var formatHash = [];
  for (var key in mapData) {
    var value = mapData[key];
    if (key === 'type') {
      value = mapTypes[mapData.type]
    }
    formatHash.push(value);
  }
  window.location.hash = '#' + formatHash.join('/');
  storeCookie(cookieName, mapData);
}

function getMapDataFromHashUrl() {
  var hash = window.location.hash;
  if (hash.length > 0) {
    hash = hash.replace('#', '');

    // Add support old hash format: #l=55.23777,23.871,8,L
    var result = hash.match(new RegExp('l=([^]+)'));
    if (result) {
      var mapQueries = result[1].split(',');
      return {
        lat: parseFloat(mapQueries[0]),
        lng: parseFloat(mapQueries[1]),
        zoom: parseInt(mapQueries[2])
      };
    }

    var mapQueries = hash.split('/');

    // Add support old hash format: #8/55.23777/23.871
    if (mapQueries.length === 3) {
      return {
        zoom: parseFloat(mapQueries[0]),
        lat: parseFloat(mapQueries[1]),
        lng: parseFloat(mapQueries[2])
      }
    }

    if (mapQueries.length < 6) {
      return null;
    }

    var type = defaultType;
    for (var key in mapTypes) {
      if (mapTypes[key] === mapQueries[0]) {
        type = key;
        break;
      }
    }

    return {
      type: type,
      zoom: parseFloat(mapQueries[1]),
      lat: parseFloat(mapQueries[2]),
      lng: parseFloat(mapQueries[3]),
      bearing: parseInt(mapQueries[4]),
      pitch: parseInt(mapQueries[5])
    };
  }
  return null;
}

function setMapData() {
  mapData.zoom = Number(map.getZoom().toFixed(2));
  mapData.lat = Number(map.getCenter().lat.toFixed(5));
  mapData.lng = Number(map.getCenter().lng.toFixed(5));
  mapData.bearing = parseInt(map.getBearing());
  mapData.pitch = parseInt(map.getPitch());
}

function storeCookie(name, value) {
  var date = new Date();
  date.setDate(date.getDate() + 365);
  var expires = "expires=" + date.toUTCString();
  document.cookie = name + '=' + JSON.stringify(value) + ';domain=.' + window.location.host.toString() + ';path=/;' + expires;
}

function readCookie(name) {
  var result = document.cookie.match(new RegExp(name + '=([^;]+)'));
  if (result) {
    return JSON.parse(result[1]);
  }
  return null;
}

function poiInteractive() {
  map.off('mouseenter', interactiveLayerId, addMousePointerCursor);
  map.off('mouseleave', interactiveLayerId, removeMousePointerCursor);
  map.off('click', interactiveLayerId, poiOnClick);

  if (map.getLayer(interactiveLayerId)) {
    map.on('mouseenter', interactiveLayerId, addMousePointerCursor);
    map.on('mouseleave', interactiveLayerId, removeMousePointerCursor);
    map.on('click', interactiveLayerId, poiOnClick);
  }
}

function addMousePointerCursor() {
  map.getCanvas().style.cursor = 'pointer';
}

function removeMousePointerCursor() {
  map.getCanvas().style.cursor = '';
}

function poiOnClick(e) {
  var poi = e.features[0];
  var html = getHtml(poi).join('<br />');

  if (html.length) {
    new mapboxgl.Popup()
      .setLngLat(poi.geometry.coordinates)
      .setHTML(html)
      .addTo(map);
  }
}

function getHtml(poi) {
  return showAttributes
    .filter(function (prop_name) {
      return poi.properties[prop_name];
    })
    .map(function (prop_name) {
      var formatedValue = getFomatedValue(prop_name, poi.properties[prop_name]);

      if (icons[prop_name]) {
        return '<i class="' + icons[prop_name] + '"></i> ' + formatedValue;
      }

      if (label[prop_name]) {
        return '<strong>' + label[prop_name] + ':</strong> ' + formatedValue;
      }

      return formatedValue;
    });
}

function getFomatedValue(attribute, value) {
  switch (attributeType[attribute]) {
    case 'bold':
      return '<strong>' + value + '</strong>';
    case 'link':
      return '<a href="' + value + '" target="_blank">' + value + '</a>';
    case 'image':
      return '<img src="' + value + '" />';
  }

  return value;
}