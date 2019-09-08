var typeIcons = {
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
     default: 'marker'
   },
   man_made: {
     tower: 'marker',
     default: 'marker'
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
     hotel: 'lodging',
     museum: 'museum',
     picnic_site: 'picnic-site',
     viewpoint: 'viewpoint',
     zoo: 'zoo',
     theme_park: 'theme_park',
     default: 'marker'
   },
   historic: {
     archaeological_site: 'hillfort',
     memorial: 'memorial',
     manor: 'marker',
     monastery: 'marker',
     default: 'marker'
   },
   railway: {
     station: 'rail',
     default: 'marker'
   },
   aeroway: {
     terminal: 'airport',
     helipad: 'heliport',
     aerodrome: 'airfield',
     default: 'marker'
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
     default: 'shop'
   },
   office: {
     government: 'town-hall',
     notary: 'marker',
     lawyer: 'marker',
     default: 'marker'
   },
   default: 'marker'
};

var formatResult = function () {
    return function (feature) {
        var formatted = '';
        if (feature.properties.name) {
            formatted = feature.properties.name;
        }

        if (feature.properties.street) {
            if (formatted.length) {
                formatted += ', ';
            }
            formatted += feature.properties.street;
        }

        if (feature.properties.housenumber) {
            if (formatted.length) {
                formatted += ' ';
            }
            formatted += feature.properties.housenumber;
        }

        if (feature.properties.city) {
            if (formatted.length) {
                formatted += ', ';
            }
            formatted += feature.properties.city;
        }

        if (feature.properties.postcode) {
            if (formatted.length) {
                formatted += ' ';
            }
            formatted += 'LT-' + feature.properties.postcode;
        }

        return formatted;
    };
};

var searchEngine = new PhotonAddressEngine({
    url: 'https://openmap.lt',
    limit: 10,
    lang: 'lt',
    formatResult: formatResult()
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

function imgSprite(name, value) {
    var icon = typeIcons.default;
    if (typeIcons[name]) {
      icon = typeIcons[name][value] || typeIcons[name].default;
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
    display: 'description',
    source: searchEngine.ttAdapter(),
    templates: {
        suggestion: function (context) {
         console.log(context);
         return '<div>' + imgSprite(context.properties.osm_key, context.properties.osm_value) + context.description + '</div>';
        }
    }
});

searchEngine.bindDefaultTypeaheadEvent($('#searchInput'));
