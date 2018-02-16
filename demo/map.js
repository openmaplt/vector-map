var interactiveLayerId = 'label-amenity';
var defaultType = defaultType || 'map';
var cookieName = defaultType + 'Data';
var popupPoi = null;
var pMaxBounds;
var pMinZoom;
var pMaxZoom;
var pZoom;
var pCenter;

var mapTypes = mapTypes || {
  map: 'm',
  orto: 'o',
  hybrid: 'h'
};
var mapData = {
  type: defaultType,
  zoom: 7,
  lat: 55.19114,
  lng: 23.87100,
  bearing: 0,
  pitch: 0
};

var showAttributes = [
  'name',
  'official_name',
  'alt_name',
  'street',
  'opening_hours',
  'email',
  'phone',
  'website',
  'heritage',
  'wikipedia',
  'height',
  'fee',
  'image',
  'style_lager'
];

var label = {
  official_name: 'Oficialus pavadinimas',
  alt_name: 'Kiti pavadinimai',
  street: 'Adresas',
  email: 'E-paštas',
  phone: 'Telefono nr.',
  fee: 'Mokestis'
};

var icons = {
  opening_hours: "fa fa-clock-o",
  email: 'fa fa-envelope-o',
  phone: 'fa fa-phone',
  website: 'fa fa-globe',
  heritage: 'fa fa-globe',
  wikipedia: 'fa fa-wikipedia-w',
  height: 'fa fa-arrows-v',
  style_lager: 'fa fa-beer',
  street: 'fa fa-address-card'
};

var attributeType = {
  name: 'bold',
  website: 'link',
  image: 'image',
  street: 'address',
  heritage: 'kvr_link',
  wikipedia: 'wikipedia',
  height: 'height',
  fee: 'fee',
  style_lager: 'beer_styles'
};
var legendData = legendData || {};
var legendTechUrl = legendTechUrl || null;

var layerCode = {
  a: 'label-address',
  p: 'label-amenity'
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
    zoom: pZoom || mapData.zoom,
    minZoom: pMinZoom || 7,
    maxZoom: pMaxZoom || 18,
    center: pCenter || [mapData.lng, mapData.lat],
    hash: false,
    maxBounds: pMaxBounds || [20.700, 53.700, 27.050, 56.650],
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
    })
    .on('load', function() {
      showLegend();
    })
    .on('click', 'label-address', poiOnClick)
    .on('mouseenter', 'label-address', addMousePointerCursor)
    .on('mouseleave', 'label-address', removeMousePointerCursor)
    .once('data', showDirectObject)
  ;
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
  mapData.id = null;
  changeHashUrl(mapData);
});

function getUrlHash(state) {
  var hash = [];
  for (var key in state) {
    var value = state[key];
    if (key === 'type') {
      value = mapTypes[state.type]
    }
    hash.push(value);
  }
  return hash.join('/');
};

function changeHashUrl() {
  var hash = getUrlHash(mapData);
  window.location.hash = '#' + hash;
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
      pitch: parseInt(mapQueries[5]),
      objectId: mapQueries[6] || null
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
  if (popupPoi) {
    popupPoi.remove();
    popupPoi = null;
  }
  var poi = e.features[0];
  var html = getHtml(poi).join('<br />');
  html += '<br />' + getDirectLink(poi);
  try {
    html += '<br />' + getOSMLink(poi);
  } catch (err) {
    console.error(err);
  }
  popupPoi = new mapboxgl.Popup();
  popupPoi
      .setLngLat(poi.geometry.coordinates)
      .setHTML(html)
      .addTo(map)
      .once('close', onPoiPopupClose);
  try {
    mapData.objectId = getObjectId(poi.properties, poi.layer);
    changeHashUrl();
  } catch (err) {
    delete mapData.objectId;
  }
}

function onPoiPopupClose() {
  if (typeof mapData.objectId !== 'undefined') {
    delete mapData.objectId;
    changeHashUrl();
  }
  popupPoi = null;
};

function getHtml(poi) {
  return showAttributes
    .filter(function (prop_name) {
      return poi.properties[prop_name];
    })
    .map(function (prop_name) {
      var formatedValue = getFomatedValue(prop_name, poi.properties);

      if (icons[prop_name]) {
        return '<span class="icon"><i class="' + icons[prop_name] + '"></i></span> ' + formatedValue;
      }

      if (label[prop_name]) {
        return '<strong>' + label[prop_name] + ':</strong> ' + formatedValue;
      }

      return formatedValue;
    });
}

function getFomatedValue(attribute, properties) {
  var value = properties[attribute];
  switch (attributeType[attribute]) {
    case 'bold':
      return '<strong>' + value + '</strong>';
    case 'height':
      return value + ' m.';
    case 'fee':
      return value === 'yes' ? 'Yra' : 'Nėra';
    case 'link':
      return '<a href="' + value + '" target="_blank">' + value + '</a>';
    case 'kvr_link':
      return '<a href="https://kvr.kpd.lt/heritage/Pages/KVRDetail.aspx?lang=lt&MC=' + value + '" target="_blank">Kultūros vertybių registras</a>';
    case 'image':
      return '<img src="' + value + '" />';
    case 'address':
      return getAddress(properties);
    case 'wikipedia':
      var splitValue = value.split(':');
      return '<a href="https://' + splitValue[0] + '.wikipedia.org/wiki/' + splitValue[1].replace(/\s/g, '_') + '" target="_blank">' + splitValue[1] + '</a>';
    case 'beer_styles':
      var styles = [];
      if (properties['style_lager'] == 'y') {
        styles.push('lageris');
      }
      if (properties['style_ale'] == 'y') {
        styles.push('elis');
      }
      if (properties['style_stout'] == 'y') {
        styles.push('stautas');
      }
      if (properties['style_ipa'] == 'y') {
        styles.push('IPA');
      }
      if (properties['style_wheat'] == 'y') {
        styles.push('kvietinis');
      }
      return '<b>Stiliai:</b> ' + styles.join(', ');
  }

  return value;
}

function showLegend() {
  if (Object.keys(legendData).length === 0) {
    return;
  }

  var legendBlock = document.createElement('div');;
  legendBlock.id = 'legend';
  legendBlock.classList.add('map-overlay');

  var legendHeader = document.createElement('strong');
  legendHeader.classList.add('legend-header');
  legendHeader.innerHTML = 'Sutartiniai ženklai';
  legendHeader.addEventListener('click', function (e) {
    e.stopPropagation();
    legendBlock.classList.toggle('active');
  });
  legendBlock.addEventListener('click', function(e) {
    e.stopPropagation();
    legendBlock.classList.add('active');
  });
  document.body.addEventListener('click', function() {
    if (legendBlock.classList.contains('active')) {
      legendBlock.classList.remove('active');
    }
  });

  legendBlock.appendChild(legendHeader);

  var ul = document.createElement('ul');
  ul.classList.add('legend-items');

  for (var key in legendData) {
    if (!legendData.hasOwnProperty(key)) {
      continue;
    }

    var legend = legendData[key];

    if (!legend.type) {
      continue;
    }

    var legendSymbolIcon = document.createElement('span');
    legendSymbolIcon.classList.add('label-' + legend.type, key);

    var legendSymbol = document.createElement('span');
    legendSymbol.classList.add('label-item');
    legendSymbol.appendChild(legendSymbolIcon);

    var legendItem = document.createElement('li');
    legendItem.appendChild(legendSymbol);
    legendItem.insertAdjacentHTML('beforeend', legend.label);

    ul.appendChild(legendItem);
  }
  legendBlock.appendChild(ul);

  if (legendTechUrl) {
    var legendUrl = document.createElement('a');
    legendUrl.classList.add('legend-doc');
    legendUrl.setAttribute('href', legendTechUrl);
    legendUrl.setAttribute('target', '_blank');
    legendUrl.innerHTML = 'Techninė informacija';
    legendBlock.appendChild(legendUrl);
  }

  document.body.appendChild(legendBlock);
};

function getAddress(properties) {
  var address = '';
  if ('street' in properties) {
    address += properties.street;
  }
  if ('housenumber' in properties) {
    address += ' ' + properties.housenumber;
  }
  if ('city' in properties) {
    address += ', ' + properties.city;
  }
  if ('post_code' in properties) {
    var code = properties.post_code;
    if (code.match(/\d+/)) {
      code = 'LT-' + code;
    }
    address += ' ' + code;
  }

  return address;
};

function getLayerCode(layerId) {
  return Object.keys(layerCode).filter(function(key) {return layerCode[key] === layerId;})[0] || '';
};

function getObjectId(properties, layer) {
  if (typeof properties.id === "undefined") {
    throw new Error('Missing object id');
  }
  return getLayerCode(layer.id) + properties.id;
};

function getDirectLink(feature) {
  var coordinates = feature.geometry.coordinates;
  var state = Object.assign({}, mapData);
  state.lat = coordinates[1].toFixed(5);
  state.lng = coordinates[0].toFixed(5);
  var properties = feature.properties;
  try {
    state.objectId = getObjectId(properties, feature.layer);
  } catch (err) {
    delete state.objectId;
  }

  var hash = getUrlHash(state);
  var url = window.location.origin + '#' + hash;

  return '<span class="icon"><i class="fa fa-link"></i></span>&nbsp;<a href="' + url + '">Tiesioginė nuoroda</a>';
};

function showDirectObject(e) {
  if (typeof mapData.objectId !== 'string') {
    return;
  }
  // repeat until source is loaded
  if (!e.isSourceLoaded) {
    map.once('data', showDirectObject);
    return;
  }
  var layers = [];
  var objectId = mapData.objectId;
  var code = objectId.charAt(0);
  if (layerCode.hasOwnProperty(code)) {
    layers.push(layerCode[code]);
    objectId = objectId.substr(1);
  }
  // lookup for feature and trigger popup on success
  var options = {
      layers: layers,
      filter: ['==', 'id', parseInt(objectId)]
  };
  var features = map.queryRenderedFeatures(options);
  if (features.length > 0) {
    poiOnClick({features: features});
  }
};

function getOSMLink(feature) {
  var properties = feature.properties;
  if (typeof properties.id === 'undefined' || typeof properties.__type__ === 'undefined') {
    console.log(properties);
    throw new Error('Cannot create OSM link');
  }
  var url = 'https://www.openstreetmap.org/';
  switch (properties.__type__) {
    case 'n':
      url += 'node';
      break;
    case 'w':
      url += 'way';
      break;
    case 'r':
      url += 'relation';
      break;
    default:
      throw new Error('Unknown object type ' + properties.__type__);
  }
  url += '/' + properties.id;

  return '<span class="icon"><i class="fa fa-database"></i></span>&nbsp;<a href="' + url + '" target="_blank">OSM duomenys</a>';
}

