import MapboxGl from 'mapbox-gl'

let interactiveLayerId = 'label-amenity';
let defaultType = 'map';
let cookieName = defaultType + 'Data';
let popupPoi = null;
let pMaxBounds;
let pMinZoom;
let pMaxZoom;
let pZoom;
let pCenter;

const mapData = {
  type: defaultType,
  zoom: 7,
  lat: 55.19114,
  lng: 23.87100,
  bearing: 0,
  pitch: 0
};

const map = new MapboxGl.Map({
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