var extended = false;
var c;
var e;
var initial_map;
var s_initial = '<img id="sw_orto" src="map_orto.png" onClick="sw_toggle_map()"><br><span id="sw_base_title">Orto</span>';
var s_ex = [{
    name: 'map_general',
    title: 'Bendras',
    html: '<div id="sw1" class="sw_map sw_map1 sw_map_hidden" onClick="sw_switch_to_map(\'-\')"><img src="map_general.png"><br>Bendras</div>'
  },
  {
    name: 'map',
    title: 'Lankytinos',
    html: '<div id="sw2" class="sw_map sw_map2 sw_map_hidden" onClick="sw_switch_to_map(\'places\')"><img src="map.png"><br>Lankytinos</div>'
  },
  {
    name: 'map_bicycle',
    title: 'Dviračiai',
    html: '<div id="sw3" class="sw_map sw_map3 sw_map_hidden" onClick="sw_switch_to_map(\'dviraciai\')"><img src="map_bicycle.png"><br>Dviračiai</div>'
  },
  {
    name: 'map_topo',
    title: 'Topografinis',
    html: '<div id="sw4" class="sw_map sw_map4 sw_map_hidden" onClick="sw_switch_to_map(\'topo\')"><img src="map_topo.png"><br>Topografinis</div>'
  },
  {
    name: 'map_upes',
    title: 'Upės (baidarės)',
    html: '<div id="sw5" class="sw_map sw_map5 sw_map_hidden" onClick="sw_switch_to_map(\'upes\')"><img src="map_upes.png"><br>Upės (baidarės)</div>'
  },
  {
    name: 'map_craftbeer',
    title: 'Craft alus',
    html: '<div id="sw6" class="sw_map sw_map6 sw_map_hidden" onClick="sw_switch_to_map(\'craftbeer\')"><img src="map_craftbeer.png"><br>Craft alus</div>'
  }];
var s_extended='';
var isDown = false;
var startX;
var scrollLeft;
var moved = false;
var orto = false;
var img_orto = 'map_orto.png';
var img_map;
var base_title;
function sw_init(m) {
  initial_map = m;
  img_map = m + '.png';
  c = document.getElementById('sw_container');
  c.classList.add('sw_container');
  c.innerHTML = '<div id="sw_extend" onClick="sw_toggle()"><img id="sw_button" src="expand_button.png"></div><div id="sw_list" class="sw_list"></div>';
  e = document.getElementById('sw_list');
  e.innerHTML = s_initial;
  for (var i=0; i<s_ex.length; i++) {
    if (s_ex[i].name == m) {
      base_title = s_ex[i].title;
    } else {
      s_extended += s_ex[i].html;
    }
  }
} // init

function sw_toggle() {
  if (!extended) {
    c.classList.add("sw_container_extended");
    e.classList.add("sw_list_extended");
    e.innerHTML = s_extended;
    setTimeout(function() {
      var x = document.getElementsByClassName('sw_map_hidden');
      while (x[0]) {
        x[0].classList.remove('sw_map_hidden');
      }
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
    c.classList.remove("sw_container_extended");
    e.classList.remove("sw_list_extended");
    e.innerHTML = s_initial;
    document.getElementById('sw_button').src = 'expand_button.png';
  }
  extended = !extended;
} // sw_toggle
function sw_switch_to_map(m) {
  if (!moved) {
    var zoom;
    var cent;
    if (initial_map == 'map') {
      zoom = map.getView().getZoom() - 1;
      cent = ol.proj.transform(map.getView().getCenter(), 'EPSG:102100', 'EPSG:4326');
      cent.lat = cent[1];
      cent.lng = cent[0];
    } else {
      zoom = map.getZoom();
      cent = map.getCenter();
    }
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
    } else if (m == 'craftbeer') {
      x = 'c';
    }
    if (m == 'places') {
      website = website + 'openmap.lt/#m=' + Math.trunc(zoom + 1) + '/' + cent.lng + '/' + cent.lat + '//T';
    } else if (m == 'upes') {
      website = website + 'openmap.lt/#' + zoom + '/' + cent.lat + '/' + cent.lng + '/0/0';
    } else {
      website = website + 'openmap.lt/#' + x + '/' + zoom + '/' + cent.lat + '/' + cent.lng + '/0/0';
    }
    window.location.href = website;
  }
} // sw_switch_to_map
function sw_toggle_map() {
  document.getElementById('sw_orto').src = orto ? img_orto : img_map;
  document.getElementById('sw_base_title').innerHTML = orto ? "Orto" : base_title;
  if (orto) {
    toMap();
  } else {
    toOrto();
  }
  orto = !orto;
} // sw_toggle_map
