var extended = 0;
var c;
var e;
var s_initial = '<img id="sw_orto" src="map_orto.png" onClick="sw_toggle_map()"><br>Orto';
var s_extended = '<div id="sw1" class="sw_map sw_map1 sw_map_hidden" onClick="sw_switch_to_map(\'-\')"><img src="map_general.png"><br>Bendras</div>' +
                 '<div id="sw2" class="sw_map sw_map2 sw_map_hidden" onClick="sw_switch_to_map(\'places\')"><img src="map.png"><br>Lankytinos</div>' +
                 '<div id="sw3" class="sw_map sw_map3 sw_map_hidden" onClick="sw_switch_to_map(\'dviraciai\')"><img src="map_bicycle.png"><br>Dviračiai</div>' +
                 '<div id="sw4" class="sw_map sw_map4 sw_map_hidden" onClick="sw_switch_to_map(\'topo\')"><img src="map_topo.png"><br>Topografinis</div>' +
                 '<div id="sw5" class="sw_map sw_map5 sw_map_hidden" onClick="sw_switch_to_map(\'upes\')"><img src="map_upes.png"><br>Upės (baidarės)</div>';
var isDown = false;
var startX;
var scrollLeft;
var moved = false;
var orto = false;
var img_orto = 'map_orto.png';
var img_map;
function sw_init(m) {
  img_map = m + '.png';
  c = document.getElementById('sw_container');
  c.classList.add('sw_container');
  c.innerHTML = '<div id="sw_extend" onClick="sw_toggle()"><img id="sw_button" src="expand_button.png"></div><div id="sw_list" class="sw_list"></div>';
  e = document.getElementById('sw_list');
  e.innerHTML = s_initial;
} // init

function sw_toggle() {
  if (extended == 0) {
    extended = 1;
    c.classList.add("sw_container_extended");
    e.classList.add("sw_list_extended");
    e.innerHTML = s_extended;
    setTimeout(function() {
      document.getElementById('sw1').classList.remove('sw_map_hidden');
      document.getElementById('sw2').classList.remove('sw_map_hidden');
      document.getElementById('sw3').classList.remove('sw_map_hidden');
      document.getElementById('sw4').classList.remove('sw_map_hidden');
      document.getElementById('sw5').classList.remove('sw_map_hidden');
      isDown = false;
      e.addEventListener('mousedown', (ev) => {
        ev.preventDefault();
        isDown = true;
        moved = false;
        startX = ev.pageX - e.offsetLeft;
        scrollLeft = e.scrollLeft;
      });
      e.addEventListener('touchstart', (ev) => {
        //ev.preventDefault();
        touch = ev.changedTouches[0];
        isDown = true;
        startX = touch.pageX - e.offsetLeft;
        scrollLeft = e.scrollLeft;
      });
      e.addEventListener('mouseleave', () => {
        isDown = false;
        moved = true;
      });
      e.addEventListener('mouseup', () => {
        isDown = false;
      });
      e.addEventListener('touchend', () => {
        isDown = false;
      });
      e.addEventListener('touchmove', (ev) => {
        if (!isDown) return;
        ev.preventDefault();
        touch = ev.changedTouches[0];
        const x = touch.pageX - e.offsetLeft;
        const walk = (x - startX);
        e.scrollLeft = scrollLeft - walk;
      });
      e.addEventListener('mousemove', (ev) => {
        if (!isDown) return;
        ev.preventDefault();
        const x = ev.pageX - e.offsetLeft;
        const walk = (x - startX);
        e.scrollLeft = scrollLeft - walk;
        moved = true;
      });
      document.getElementById('sw_button').src = 'contract_button.png';
    }, 0);
  } else {
    extended = 0;
    c.classList.remove("sw_container_extended");
    e.classList.remove("sw_list_extended");
    e.innerHTML = s_initial;
    document.getElementById('sw_button').src = 'expand_button.png';
  }
} // sw_toggle
function sw_switch_to_map(m) {
  if (!moved) {
    var zoom = map.getZoom();
    var cent = map.getCenter();
    var website = "https://";
    var x;
    if (m != '-') {
      website = website + m + '.';
    }
    if (m == '-') {
      x = 'm';
    } else if (m == 'topo') {
      x = 't';
    } else if (m == 'upes') {
      x = '';
    } else if (m == 'dviraciai') {
      x = 'b';
    }
    if (m == 'places') {
      website = website + 'openmap.lt/#m=' + Math.trunc(zoom) + '/' + cent.lng + '/' + cent.lat + '//T';
    } else {
      website = website + 'openmap.lt/#' + x + '/' + zoom + '/' + cent.lat + '/' + cent.lng + '/0/0';
    }
    window.location.href = website;
  }
} // sw_switch_to_map
function sw_toggle_map() {
  document.getElementById('sw_orto').src = orto ? img_orto : img_map;
  if (orto) {
    toMap();
  } else {
    toOrto();
  }
  orto = !orto;
} // sw_toggle_map
