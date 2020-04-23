const defaultType = 'map';
const defaultLat = 55.19114;
const defaultLng = 23.87100;
const defaultZoom = 7;
const mapTypes = {
  map: 'm',
  orto: 'o',
  hybrid: 'h'
};

let mapData = {
  type: defaultType,
  zoom: defaultZoom,
  lat: defaultLat,
  lng: defaultLng,
  bearing: 0,
  pitch: 0
};

if (hashData = getMapDataFromHashUrl()) {
  mapData = Object.assign(mapData, hashData);
}

const canvas = document.getElementById("map");

const map = new harp.MapView({
  canvas: canvas,
  theme: "https://unpkg.com/@here/harp-map-theme@latest/resources/berlin_tilezen_base_globe.json",
  target: {
    lat: mapData.lat || defaultLat,
    lng: mapData.lng || defaultLng
  },
  minZoomLevel: 8,
  maxZoomLevel: 18,
  zoomLevel: mapData.zoom || defaultZoom,
  tilt: mapData.pitch,
  heading: mapData.bearing,
});

map.addEventListener(harp.MapViewEventNames.CameraPositionChanged, changeHashUrl);

const mapControls = new harp.MapControls(map);
const ui = new harp.MapControlsUI(mapControls);
canvas.parentElement.appendChild(ui.domElement);

const omvDataSource = new harp.OmvDataSource({
  url: "https://openmap.lt/maps/all/{z}/{x}/{y}.pbf",
  apiFormat: harp.APIFormat.XYZMVT,
  styleSetName: "tilezen",
});
map.addDataSource(omvDataSource);

function setMapData(event) {
  mapData.zoom = Number(event.zoom.toFixed(2));
  mapData.lat = Number(event.latitude.toFixed(5));
  mapData.lng = Number(event.longitude.toFixed(5));
  mapData.bearing = parseInt(event.heading);
  mapData.pitch = parseInt(event.tilt);
}

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
}

function changeHashUrl(event) {
  setMapData(event)
  const hash = getUrlHash(mapData);
  window.location.hash = '#' + hash;
}

function getMapDataFromHashUrl() {
  let hash = window.location.hash;
  if (hash.length > 0) {
    hash = hash.replace('#', '');

    // Add support old hash format: #l=55.23777,23.871,8,L
    const result = hash.match(new RegExp('l=([^]+)'));
    if (result) {
      const mapQueries = result[1].split(',');
      return {
        lat: parseFloat(mapQueries[0]),
        lng: parseFloat(mapQueries[1]),
        zoom: parseInt(mapQueries[2])
      };
    }

    const mapQueries = hash.split('/');

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

    let type = defaultType;
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
