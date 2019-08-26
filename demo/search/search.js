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
    limit: 15,
    lang: 'lt',
    formatResult: formatResult()
});

$('#searchInput').typeahead({
    minLength: 3,
    hint: false,
    highlight: true,
}, {
    limit: 15,
    displayKey: 'description',
    source: searchEngine.ttAdapter(),
});

searchEngine.bindDefaultTypeaheadEvent($('#searchInput'));