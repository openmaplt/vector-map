var defaultType = 'beer_dark';
var mapTypes = {
  beer_dark: 'c'
};
var filterCond = 'any';
var filterPlace = 'drink';
function change() {
  var filters = [filterCond];
  if (document.getElementById("label-lager").checked) {
    filters.push(['==', 'style_lager', 'y']);
  }
  if (document.getElementById("label-ale").checked) {
    filters.push(['==', 'style_ale', 'y']);
  }
  if (document.getElementById("label-wheat").checked) {
    filters.push(['==', 'style_wheat', 'y']);
  }
  if (document.getElementById("label-stout").checked) {
    filters.push(['==', 'style_stout', 'y']);
  }
  if (document.getElementById("label-ipa").checked) {
    filters.push(['==', 'style_ipa', 'y']);
  }
  var filterMain = ['all'];
  if (filterPlace === 'drink') {
    filterMain.push(['==', 'drink', 'y']);
  } else {
    filterMain.push(['==', 'shop', 'y']);
  }
  filterMain.push(filters.length > 1 ? filters : null);
  map.setFilter('label-amenity', filterMain);
}
function changeCond(f) {
  filterCond = f;
  if (f === 'any') {
    document.getElementById("label-or").checked = true;
    document.getElementById("label-and").checked = false;
  } else {
    document.getElementById("label-or").checked = false;
    document.getElementById("label-and").checked = true;
  }
  change();
}
function changeType(f) {
  filterPlace = f;
  if (f === 'drink') {
    document.getElementById("label-drink").checked = true;
    document.getElementById("label-shop").checked = false;
  } else {
    document.getElementById("label-drink").checked = false;
    document.getElementById("label-shop").checked = true;
  }
  change();
}