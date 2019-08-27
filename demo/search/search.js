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

function imgSprite(name) {
    if (sprite[name]) {
        return '<img src="img_trans.gif" style="width: ' + sprite[name].width +
            'px; height: ' + sprite[name].height +
            'px; background: url(search/sprites/openmaplt.png) -' + sprite[name].x + 'px -' + sprite[name].y + 'px;">';
    }
    return '<img src="img_trans.gif" />';
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
         return '<div>' + imgSprite(context.properties.osm_key) + context.description + '</div>';
        }
    }
});

searchEngine.bindDefaultTypeaheadEvent($('#searchInput'));