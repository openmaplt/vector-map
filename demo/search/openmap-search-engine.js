/**
 * OpenMap Search Engine - Vanilla JavaScript version
 * Replaces the jQuery-dependent typeahead-openmap.js
 */
class OpenMapSearchEngine extends EventTarget {
  constructor(options = {}) {
    super();
    this.options = {
      formatResult: options.formatResult || ((feature) => feature.name),
      reqParams: {},
      ...options
    };
  }

  /**
   * Search function compatible with SimpleAutocomplete
   */
  search(query, callback) {
    if (query.length < 3) {
      callback([]);
      return;
    }

    const searchData = {
      ...this.options.reqParams,
      q: query
    };

    // Convert object to URLSearchParams
    const params = new URLSearchParams();
    Object.keys(searchData).forEach(key => {
      params.append(key, searchData[key]);
    });

    fetch('/api/search?' + params.toString())
      .then(response => response.json())
      .then(data => {
        const results = data.hits.hits.map(feature => {
          const result = feature._source;
          result._description = this.options.formatResult(feature._source);
          return result;
        });
        
        // Trigger predictions event
        this.dispatchEvent(new CustomEvent('addresspicker:predictions', {
          detail: results
        }));
        
        callback(results);
      })
      .catch(error => {
        console.error('Search error:', error);
        callback([]);
      });
  }

  /**
   * Bind selection event to the autocomplete input
   */
  bindSelectionEvent(input) {
    input.addEventListener('autocomplete:selected', (event) => {
      const selectedPlace = event.detail;
      
      // Trigger addresspicker:selected event
      this.dispatchEvent(new CustomEvent('addresspicker:selected', {
        detail: selectedPlace
      }));
    });
  }
}

// Export for use in other scripts
window.OpenMapSearchEngine = OpenMapSearchEngine;