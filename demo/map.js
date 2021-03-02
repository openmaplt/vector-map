var interactiveLayerId = 'label-amenity';
var defaultType = defaultType || 'map';
var defaultLat = defaultLat || 55.19114;
var defaultLng = defaultLng || 23.87100;
var defaultZoom = defaultZoom || 7;
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
  zoom: defaultZoom,
  lat: defaultLat,
  lng: defaultLng,
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
  phone: 'phone',
  style_lager: 'beer_styles',
  opening_hours: 'opening_hours'
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
    pitch: mapData.pitch,
    attributionControl: false
  })
    .addControl(new mapboxgl.NavigationControl(), 'top-left')
    .addControl(new mapboxgl.GeolocateControl({
      positionOptions: {
        enableHighAccuracy: true
      },
      trackUserLocation: true
    }), 'top-left')
    .addControl(new mapboxgl.AttributionControl(), 'bottom-left')
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

if (typeof searchEngine !== 'undefined') {
  var searchMarker = null;
  $(searchEngine).bind('addresspicker:selected', function (event, selectedPlace) {
    if (!searchMarker) {
      searchMarker = new mapboxgl.Marker();
    }
    searchMarker
        .setLngLat([selectedPlace.location[1], selectedPlace.location[0]])
        .addTo(map);

    /*if (selectedPlace.properties.extent) {
      const extent = selectedPlace.properties.extent;
      map.fitBounds([[extent[0], extent[3]], [extent[2], extent[1]]], {
          speed: 2
      });
    } else {*/
      map.flyTo({
        zoom: 16,
        speed: 2,
        center: searchMarker.getLngLat()
      });
    // }
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
  document.cookie = name + '=' + JSON.stringify(value) + ';domain=.' + window.location.host.toString() + ';path=/;' + expires + ';secure;samesite=strict';
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
  // move to vertical center on portrait mode
  if (screen.width < screen.height) {
      var center = map.getCenter();
      map.flyTo({
          center: {
              lat: center.lat,
              lng: poi.geometry.coordinates[0]
          }
      });
  }
  var lines = getHtml(poi);
  try {
    lines.push(getOSMLink(poi));
  } catch (err) {
    console.error(err);
  }
  popupPoi = new mapboxgl.Popup();
  popupPoi
      .setLngLat(poi.geometry.coordinates)
      .setHTML(lines.join('<br />'))
      .setMaxWidth('70vw')
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
      return '<a href="' + value + '" target="_blank"><img src="' + value + '" /></a>';
    case 'address':
      return getAddress(properties);
    case 'phone':
      return '<a href="tel:' + value + '">' + value + '</a>';
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
    case 'opening_hours':
      var parts = value
        .replace(/(\d)\s*,\s*(\w)/g, "$1;$2")
        .replace('Mo', 'Pr')
        .replace('Tu', 'An')
        .replace('We', 'Tr')
        .replace('Th', 'Kt')
        .replace('Fr', 'Pt')
        .replace('Sa', 'Št')
        .replace('Su', 'Sk')
        .split(';');

      return parts.join('<br><span class="icon"></span> ');
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
  var base = 'https://www.openstreetmap.org/';
  var type;
  switch (properties.__type__) {
    case 'n':
      type = 'node';
      break;
    case 'w':
      type = 'way';
      break;
    case 'r':
      type = 'relation';
      break;
    default:
      throw new Error('Unknown object type ' + properties.__type__);
  }

  var link = '<span class="icon"><i class="fa fa-database"></i></span>&nbsp;<a href="' + base + type + '/' + properties.id + '" target="_blank">OSM</a>';
  link += '&nbsp;<span class="icon"><i class="fa fa-edit"></i></span>&nbsp;<a href="' + base + 'edit?' + type + '=' + properties.id + '#map=18/' + mapData.lat + '/' + mapData.lng + '" target="_blank">Edit</a>';

  return link;
}

var nowSending = false; // is currently query sent to the server and we're awaiting for result?
var searchChanges; // has the query text changed after the last query was sent to the server?
var sentText = ''; // the last query text sent to the server
function lpad000(n) {
  var words = n.split(' ');
  words.forEach((w, idx) => {
    if (/^\d$/.test(w)) {
      words[idx] = '00' + w;
    } else if (/^\d\d$/.test(w)) {
      words[idx] = '0' + w;
    }
  });
  return words.join(' ');
}
function unlpad000(n) {
  var words = n.split(' ');
  words.forEach((w, idx) => {
    if (/^00\d$/.test(w)) {
      words[idx] = w.substring(2);
    } else if (/^0\d\d$/.test(w)) {
      words[idx] = w.substring(1);
    }
  });
  return words.join(' ');
}
var searchResults = [];
function searchKey() {
  if (!nowSending && i_search_text.value != sentText) {
    // Number are lpadded with zeros so that it would be possible to find housenumber 1
    // as separate, not in 10, 17 or 571. The same is done on server side.
    const searchText = lpad000(i_search_text.value);
    console.log('Sending query! ' + searchText);
    sentText = i_search_text.value;
    const data = {
        "explain": true,
        "query": {
          "bool": {
            "should": [
              {
                "multi_match": {
                    "query": `${searchText}`,
                    "fields": ["full_text", "city", "housenumber^25", "street^15"],
                    "type": "cross_fields",
                    "boost": 20
                }
              },
              {
                "multi_match": {
                    "query": `${searchText}`,
                    "fuzziness": "AUTO"
                }
              }
            ]
          }
        },
        "highlight": {
          "fields": {
            "full_text": {},
            "housenumber": {},
            "street": {},
            "city": {}
          }
        },
        "sort": [
          "_score",
          {
            "_geo_distance": {
              "location": {
                "lat": map.getCenter().lat,
                "lon": map.getCenter().lng
              },
              "order": "asc",
              "unit": "km",
              "distance_type": "plane"
            }
          }
        ]
    }
    searchChanges = false;
    nowSending = true;
    /*fetch('https://openmap.lt/api/search', { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(data) })*/
    fetch('https://openmap.lt/api/search?source=' + encodeURI(JSON.stringify(data)) + '&source_content_type=' + encodeURI('application/json'))
      .then(response => response.json())
      .then(data => {
        i_search_results.innerHTML = '';
        searchResults = data.hits.hits;
        searchResults.forEach((el, idx) => {
          console.log(el);
          var searchResult = document.createElement('div');
          searchResult.classList.add('search_result');
          searchResult.setAttribute('idx', idx);
          searchResult.onclick = actionSearchClick;
          const i = el._source;
          var desc = i.obj_type;
          if (i.hasOwnProperty('name')) { desc += ' ' + i.name; }
          if (i.hasOwnProperty('city')) { desc += ' ' + i.city; }
          if (i.hasOwnProperty('street')) { desc += ' ' + i.street; }
          if (i.hasOwnProperty('housenumber')) { desc += ' ' + unlpad000(i.housenumber); }
          desc += ' (score: ' + el._score + ')';
          if (el.hasOwnProperty('highlight')) {
            if (el.highlight.hasOwnProperty('full_text')) {
              searchResult.innerHTML = unlpad000(el.highlight.full_text[0]);
              i_search_results.appendChild(searchResult);
            } else {
              searchResult.innerHTML = desc;
              i_search_results.appendChild(searchResult);
            }
            if (el.highlight.hasOwnProperty('street')) {
              var highlight = document.createElement('div');
              highlight.classList.add('highlight');
              highlight.innerHTML = el.highlight.street[0];
              i_search_results.appendChild(highlight);
            }
            if (el.highlight.hasOwnProperty('housenumber')) {
              var highlight = document.createElement('div');
              highlight.classList.add('highlight');
              highlight.innerHTML = el.highlight.housenumber[0];
              i_search_results.appendChild(highlight);
            }
            if (el.highlight.hasOwnProperty('city')) {
              var highlight = document.createElement('div');
              highlight.classList.add('highlight');
              highlight.innerHTML = el.highlight.city[0];
              i_search_results.appendChild(highlight);
            }
          } else {
            searchResult.innerHTML = desc;
            i_search_results.appendChild(searchResult);
          }
        });
        nowSending = false;
        if (searchChanges) {
          searchKey();
        }
        i_search_results.style.display = 'block';
      });
  } else {
    if (i_search_text.value != sentText) {
      console.log('Busy. Waiting...');
      searchChanges = true;
    }
  }
}

function actionSearchClick(e) {
  var idx = Number(e.srcElement.getAttribute('idx'));
  i_search_results.style.display = 'none';
  var coords = searchResults[idx]._source.location;
  map.flyTo({ center: [coords[1], coords[0]], zoom: 16 });
} // actionSearchClick
