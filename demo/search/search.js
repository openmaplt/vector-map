var typeIcons = {
  HIL: 'hillfort',
  TUM: 'tumulus', // pilkapiai
  MAN: 'marker', // dvaras
  MNS: 'marker', // vienuolynas
  MON: 'memorial', // memorialas
  HIS: 'marker', // kiti istoriniai
  HER: 'marker', // paveldas
  //TOW: '', // bokštas
  //ATT: '', // lankytina vieta
  //VIE: '', // vaizdinga vieta
  //MUS: '', // muziejus
  //PIF: '', // poilsiavietė
  //CAM: '', // stovyklavietė
  //GUE: '', // nakvynė
  //FUE: '', // degalinė
  //CAF: '', // kavinė
  //FAS: '', // greitas maistas
  RES: 'restaurant', // restoranas
  PUB: 'bar', // aludė
  //HOT: '', // viešbutis
  //THE: '', // teatras
  //CIN: '', // kinoteatras
  //DEN: '', // odontologas
  //DOC: '', // daktaras
  //PHA: '', // vaistinė
  //SUP: '', // parduotuvė
  //CON: '', // parduotuvė
  //CAR: '', // servisas
  //KIO: '', // kioskas
  //DIY: '', // pasidaryk pats
  //CHU: '', // bažnyčia (katalikų)
  //LUT: '', // bažnyčia (liuteronų)
  //ORT: '', // cerkvė
  //ORA: '', // kitų tikėjimų maldos namai
  //GOV: '', // valstybės įstaiga
  //COU: '', // teismas
  //NOT: '', // notaras
  //INS: '', // draudimas
  //COM: '', // įmonė
  //OSH: '', // kita parduotuvė
  //POS: '', // paštas
  //WAS: '', // mašinų plovykla
  //BAN: '', // bankas
  //ATM: '', // bankomatas
  //STO: '', // akmuo
  //TRE: '', // medis
  //SPR: '', // šaltinis
  OSH: 'shop',
  default: 'marker'
}
/*var typeIcons = {
   amenity: {
     arts_centre: 'arg-gallery',
     atm: 'marker',
     bank: 'bank',
     bar: 'bar',
     bicycle_parking: 'bicycle_parking',
     bicycle_rental: 'bicycle_rental',
     bus_station: 'bus',
     cafe: 'cafe',
     car_wash: 'marker',
     cinema: 'cinema',
     clinic: 'marker',
     courthouse: 'marker',
     compressed_air: 'compressed_air',
     dentist: 'dentist',
     doctors: 'doctor',
     embassy: 'embassy',
     fast_food: 'fast-food',
     ferry_terminal: 'ferry',
     fire_station: 'fire-station',
     fuel: 'fuel',
     hospital: 'hospital',
     kindergarten: 'scooter',
     library: 'library',
     pharmacy: 'pharmacy',
     place_of_worship: 'place_of_worship',
     police: 'police',
     post_office: 'post',
     pub: 'beer',
     restaurant: 'restaurant',
     school: 'school',
     shelter: 'shelter',
     theatre: 'theatre',
     townhall: 'town-hall',
     college: 'college',
     university: 'college',
   },
   man_made: {
     tower: 'marker',
   },
   tourism: {
     attraction: 'attraction',
     information: 'information',
     camp_site: 'campsite',
     caravan_site: 'campsite',
     chalet: 'home',
     hostel: 'home',
     motel: 'home',
     guest_house: 'home',
     apartment: 'home',
     hotel: 'lodging',
     museum: 'museum',
     picnic_site: 'picnic-site',
     viewpoint: 'viewpoint',
     zoo: 'zoo',
     theme_park: 'theme_park',
   },
   historic: {
     memorial: 'memorial',
     manor: 'marker',
     monastery: 'marker',
   },
   railway: {
     station: 'rail',
   },
   aeroway: {
     terminal: 'airport',
     helipad: 'heliport',
     aerodrome: 'airfield',
   },
   shop: {
     alcohol: 'alcohol-shop',
     car_repair: 'marker',
     bakery: 'bakery',
     bicycle: 'bicycle',
     clothes: 'clothing-store',
     supermarket: 'grocery',
     mall: 'grocery',
     department_store: 'grocery',
     convenience: 'shop',
     hairdresser: 'hairdresser',
     florist: 'florist',
     music: 'music',
     butcher: 'slaughterhouse',
   },
   office: {
     government: 'town-hall',
     notary: 'suitcase',
     lawyer: 'suitcase',
   },
   natural: {
     peak: 'mountain',
   },
   highway: {
     default: 'square-stroked'
   },
   place: {
     default: 'town'
   },
   leisure: {
     park: 'park',
     default: 'marker'
   },
   landuse: {
     cemetery: 'cemetery',
     default: 'marker'
   },
   default: 'marker'
};*/

var formatResult = function () {
    return function (feature) {
      var formatted = '';

      if (feature.name) {
          formatted += feature.name;
      }

      if (feature.street) {
          if (formatted.length) {
              formatted += ', ';
          }
          formatted += feature.street;
      }

      if (feature.housenumber) {
          if (formatted.length) {
              formatted += ' ';
          }
          formatted += feature.housenumber;
      }

      if (feature.city) {
          if (formatted.length) {
              formatted += ', ';
          }
          formatted += feature.city;
      }

      if (feature.postcode) {
          // if (feature.osm_key != 'highway') {
            if (formatted.length) {
              formatted += ' ';
            }
            formatted += 'LT-' + feature.postcode;
          // }
      }

      return formatted;
    };
};

var searchEngine = new OpenMapSearchEngine({
    formatResult: formatResult(),
});

var sprite;
var xmlhttp = new XMLHttpRequest();
xmlhttp.onreadystatechange = function() {
    if (this.readyState == 4 && this.status == 200) {
        sprite = JSON.parse(this.responseText);
    }
};
xmlhttp.open("GET", "search/sprites/openmaplt.json", true);
xmlhttp.send();

function imgSprite(type) {
    var icon = typeIcons.default;
    if (typeIcons[type]) {
      icon = typeIcons[type];
    }
    return '<img src="img_trans.gif" style="width: ' + sprite[icon].width +
           'px; height: ' + sprite[icon].height +
           'px; background: url(search/sprites/openmaplt.png) -' + sprite[icon].x + 'px -' + sprite[icon].y + 'px;">';
}

$('#searchInput').typeahead({
    minLength: 3,
    hint: false,
    highlight: true,
}, {
    limit: 10,
    display: '_description',
    source: searchEngine.ttAdapter(),
    templates: {
      suggestion: function (context) {
        return '<div>' + imgSprite(context.obj_type) + context._description + '</div>';
      }
    }
});

searchEngine.bindDefaultTypeaheadEvent($('#searchInput'));
