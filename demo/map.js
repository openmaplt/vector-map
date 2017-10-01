mapboxgl.accessToken = 'pk.eyJ1IjoiYmNhbXBlciIsImEiOiJWUmh3anY0In0.1fgSTNWpQV8-5sBjGbBzGg';

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

var map = new mapboxgl.Map({
        container: 'map',
        style: 'styles/map.json',
        zoom: 7,
        minZoom: 7,
        maxZoom: 18,
        center: [24.07, 54.96],
        hash: true,
        maxBounds: [20.880, 53.888, 26.862, 56.453]
    })
    .addControl(new mapboxgl.NavigationControl(), 'top-left')
    .addControl(new mapboxgl.GeolocateControl({
        positionOptions: {
            enableHighAccuracy: true
        },
        trackUserLocation: true
    }), 'top-left');

map.on('data', function () {
    if(map.isStyleLoaded()) {
        poiInteractive();
    }
});

$('#layers button').on('click', function(e) {
    if ($(this).hasClass('active')) {
        return false;
    }
    $('#layers button').removeClass('active');
    $(this).addClass('active');
    map.setStyle('styles/' + $(e.target).data('style') + '.json');
});

function poiInteractive()
{
    var poiLayerName = 'label-amenity';

    map.off('mouseenter', poiLayerName, addMousePointerCursor);
    map.off('mouseleave', poiLayerName, removeMousePointerCursor);
    map.off('click', poiLayerName, poiOnClick);

    if (map.getLayer(poiLayerName)) {
        map.on('mouseenter', poiLayerName, addMousePointerCursor);
        map.on('mouseleave', poiLayerName, removeMousePointerCursor);
        map.on('click', poiLayerName, poiOnClick);
    }
}

function addMousePointerCursor()
{
    map.getCanvas().style.cursor = 'pointer';
}

function removeMousePointerCursor()
{
    map.getCanvas().style.cursor = '';
}

function poiOnClick(e)
{
    var poi = e.features[0];
    var html = getHtml(poi).join('<br />');

    if(html.length) {
        new mapboxgl.Popup()
            .setLngLat(poi.geometry.coordinates)
            .setHTML(html)
            .addTo(map);
    }
}

function getHtml(poi)
{
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

function getFomatedValue(attribute, value)
{
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