/**
 * Simple Autocomplete component to replace typeahead.js
 * Vanilla JavaScript implementation without jQuery dependency
 */
class SimpleAutocomplete {
  constructor(input, options = {}) {
    this.input = typeof input === 'string' ? document.querySelector(input) : input;
    this.options = {
      minLength: options.minLength || 3,
      limit: options.limit || 10,
      display: options.display || 'value',
      source: options.source || (() => []),
      templates: options.templates || {},
      highlight: options.highlight !== false,
      ...options
    };
    
    this.isOpen = false;
    this.currentIndex = -1;
    this.suggestions = [];
    
    this.init();
  }
  
  init() {
    if (!this.input) {
      console.error('SimpleAutocomplete: Input element not found');
      return;
    }
    
    this.createDropdown();
    this.bindEvents();
  }
  
  createDropdown() {
    this.dropdown = document.createElement('div');
    this.dropdown.className = 'autocomplete-dropdown';
    this.dropdown.style.cssText = `
      position: absolute;
      top: 100%;
      left: 0;
      right: 0;
      background: white;
      border: 1px solid #ccc;
      border-top: none;
      max-height: 300px;
      overflow-y: auto;
      z-index: 1000;
      display: none;
    `;
    
    // Position relative to input
    const inputRect = this.input.getBoundingClientRect();
    this.input.parentNode.style.position = 'relative';
    this.input.parentNode.appendChild(this.dropdown);
  }
  
  bindEvents() {
    this.input.addEventListener('input', this.handleInput.bind(this));
    this.input.addEventListener('keydown', this.handleKeydown.bind(this));
    this.input.addEventListener('blur', this.handleBlur.bind(this));
    this.dropdown.addEventListener('click', this.handleDropdownClick.bind(this));
  }
  
  handleInput(e) {
    const query = e.target.value.trim();
    
    if (query.length < this.options.minLength) {
      this.close();
      return;
    }
    
    // Call the source function
    this.options.source(query, (suggestions) => {
      this.suggestions = suggestions.slice(0, this.options.limit);
      this.render();
    });
  }
  
  handleKeydown(e) {
    if (!this.isOpen) return;
    
    switch (e.key) {
      case 'ArrowDown':
        e.preventDefault();
        this.currentIndex = Math.min(this.currentIndex + 1, this.suggestions.length - 1);
        this.updateSelection();
        break;
      case 'ArrowUp':
        e.preventDefault();
        this.currentIndex = Math.max(this.currentIndex - 1, -1);
        this.updateSelection();
        break;
      case 'Enter':
        e.preventDefault();
        if (this.currentIndex >= 0) {
          this.selectSuggestion(this.suggestions[this.currentIndex]);
        }
        break;
      case 'Escape':
        this.close();
        break;
    }
  }
  
  handleBlur() {
    // Delay closing to allow click events
    setTimeout(() => this.close(), 150);
  }
  
  handleDropdownClick(e) {
    const item = e.target.closest('.autocomplete-item');
    if (item) {
      const index = parseInt(item.dataset.index);
      this.selectSuggestion(this.suggestions[index]);
    }
  }
  
  render() {
    if (!this.suggestions.length) {
      this.close();
      return;
    }
    
    const html = this.suggestions.map((suggestion, index) => {
      const displayValue = typeof suggestion === 'object' 
        ? suggestion[this.options.display] 
        : suggestion;
      
      let content = displayValue;
      if (this.options.templates.suggestion) {
        content = this.options.templates.suggestion(suggestion);
      } else if (this.options.highlight) {
        const query = this.input.value.trim();
        content = this.highlightMatch(displayValue, query);
      }
      
      return `<div class="autocomplete-item" data-index="${index}" style="padding: 8px 12px; cursor: pointer; border-bottom: 1px solid #eee;">${content}</div>`;
    }).join('');
    
    this.dropdown.innerHTML = html;
    this.open();
  }
  
  highlightMatch(text, query) {
    if (!query) return text;
    const regex = new RegExp(`(${query.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')})`, 'gi');
    return text.replace(regex, '<strong>$1</strong>');
  }
  
  updateSelection() {
    const items = this.dropdown.querySelectorAll('.autocomplete-item');
    items.forEach((item, index) => {
      item.style.backgroundColor = index === this.currentIndex ? '#f5f5f5' : '';
    });
  }
  
  selectSuggestion(suggestion) {
    const displayValue = typeof suggestion === 'object' 
      ? suggestion[this.options.display] 
      : suggestion;
    
    this.input.value = displayValue;
    this.close();
    
    // Trigger custom event
    const event = new CustomEvent('autocomplete:selected', {
      detail: suggestion
    });
    this.input.dispatchEvent(event);
  }
  
  open() {
    this.dropdown.style.display = 'block';
    this.isOpen = true;
    this.currentIndex = -1;
  }
  
  close() {
    this.dropdown.style.display = 'none';
    this.isOpen = false;
    this.currentIndex = -1;
  }
}

// Export for use in other scripts
window.SimpleAutocomplete = SimpleAutocomplete;