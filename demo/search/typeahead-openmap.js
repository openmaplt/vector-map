!(function (root, $, Bloodhound) {
  'use strict';

  /**
   * Supplier of default formatResult function.
   *
   * @return default implementation of formatResult function
   */
  var _formatResultSupplier = function () {
    return function (feature) {
      return feature.name;
    };
  };

  /**
   * Constructor of suggestion engine.
   */
  root.OpenMapSearchEngine = function (options) {
    options = options || {};

    var formatResult = options.formatResult || _formatResultSupplier(),
        reqParams = {};

    var bloodhound = new Bloodhound({
      local: [],
      queryTokenizer: Bloodhound.tokenizers.nonword,
      datumTokenizer: function (feature) {
        return Bloodhound.tokenizers.obj.whitespace([
          'name', 'street', 'housenumber', 'city', 'postcode'
        ])(feature);
      },
      remote: {
        url: '/api/search',
        prepare: function (query, settings) {
          settings.data = reqParams;
          settings.data.q = query;
          return settings;
        },
        transform: function (response) {
          return response.hits.hits.map(function (feature) {
            var result = feature._source;
            result._description = formatResult(feature._source);
            return result;
          });
        }
      }
    });

    /* Redefine bloodhound.search(query, sync, async) function */
    var _oldSearch = bloodhound.search;

    bloodhound.search = function (query, sync, async) {
      var syncPromise = jQuery.Deferred(),
          asyncPromise = jQuery.Deferred();

      _oldSearch.call(bloodhound, query, function (datums) {
        syncPromise.resolve(datums);
      }, function (datums) {
        asyncPromise.resolve(datums);
      });

      $.when(syncPromise, asyncPromise)
        .then(function (syncResults, asyncResults) {
          var allResults = [].concat(syncResults, asyncResults);

          $(bloodhound).trigger('addresspicker:predictions', [ allResults ]);

          sync(syncResults);
          async(asyncResults);
        });
    };

    /**
     * Transforms default typeahead event typeahead:selected to
     * addresspicker:selected. The same event is triggered by
     * bloodhound.reverseGeocode.
     *
     * @param typeahead jquery wrapper around address input
     */
    bloodhound.bindDefaultTypeaheadEvent = function (typeahead) {
      typeahead.bind('typeahead:selected', function (event, place) {
        $(bloodhound).trigger('addresspicker:selected', [ place ]);
      });
    };

    return bloodhound;
  };

})(this, jQuery, Bloodhound);
