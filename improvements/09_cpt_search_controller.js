// =============================================================================
// IMPROVEMENT #9: Fixed CPT Search Controller (Memory Leak Fix)
// =============================================================================
// File: app/javascript/controllers/cpt_search_controller.js
//
// Changes:
// - Added proper disconnect() method to remove event listeners
// - Used bound handler pattern for proper cleanup
// - Added debounce cleanup on disconnect
// - Added keyboard navigation support
// - Added loading state
// =============================================================================

import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  // These targets match the 'data-cpt-search-target' attributes in your HTML
  static targets = ["input", "results", "hiddenCodeField", "hiddenNameField"]
  
  // Static values for configuration
  static values = {
    url: { type: String, default: "/cpt_codes" },
    minLength: { type: Number, default: 2 },
    debounceMs: { type: Number, default: 300 }
  }

  connect() {
    // Bind the click handler so we can properly remove it later
    this.boundClickOutside = this.handleClickOutside.bind(this)
    this.boundKeydown = this.handleKeydown.bind(this)
    
    // Add event listeners
    document.addEventListener("click", this.boundClickOutside)
    this.inputTarget.addEventListener("keydown", this.boundKeydown)
    
    // Initialize state
    this.timeout = null
    this.selectedIndex = -1
    this.isLoading = false
  }

  disconnect() {
    // CRITICAL: Remove event listeners to prevent memory leaks
    document.removeEventListener("click", this.boundClickOutside)
    this.inputTarget.removeEventListener("keydown", this.boundKeydown)
    
    // Clear any pending debounce timeout
    if (this.timeout) {
      clearTimeout(this.timeout)
      this.timeout = null
    }
  }

  // Handle clicks outside the component to close dropdown
  handleClickOutside(event) {
    if (!this.element.contains(event.target)) {
      this.hideResults()
    }
  }

  // Handle keyboard navigation
  handleKeydown(event) {
    const items = this.resultsTarget.querySelectorAll("li[data-action]")
    
    switch (event.key) {
      case "ArrowDown":
        event.preventDefault()
        this.selectedIndex = Math.min(this.selectedIndex + 1, items.length - 1)
        this.highlightItem(items)
        break
        
      case "ArrowUp":
        event.preventDefault()
        this.selectedIndex = Math.max(this.selectedIndex - 1, 0)
        this.highlightItem(items)
        break
        
      case "Enter":
        event.preventDefault()
        if (this.selectedIndex >= 0 && items[this.selectedIndex]) {
          this.selectItem(items[this.selectedIndex])
        }
        break
        
      case "Escape":
        this.hideResults()
        this.inputTarget.blur()
        break
    }
  }

  highlightItem(items) {
    items.forEach((item, index) => {
      if (index === this.selectedIndex) {
        item.classList.add("bg-indigo-600", "text-white")
        item.classList.remove("hover:bg-indigo-600", "hover:text-white")
        item.scrollIntoView({ block: "nearest" })
      } else {
        item.classList.remove("bg-indigo-600", "text-white")
        item.classList.add("hover:bg-indigo-600", "hover:text-white")
      }
    })
  }

  // Triggered by 'input' event on the text box
  search() {
    // Clear any existing timeout
    if (this.timeout) {
      clearTimeout(this.timeout)
    }
    
    // Debounce: Wait for user to stop typing
    this.timeout = setTimeout(() => {
      this.fetchResults()
    }, this.debounceMs)
  }

  get debounceMs() {
    return this.hasDebounceValue ? this.debounceValue : 300
  }

  get minLength() {
    return this.hasMinLengthValue ? this.minLengthValue : 2
  }

  get searchUrl() {
    return this.hasUrlValue ? this.urlValue : "/cpt_codes"
  }

  fetchResults() {
    const query = this.inputTarget.value.trim()
    
    // Don't search if the input is too short or empty
    if (query.length < this.minLength) {
      this.hideResults()
      return
    }

    // Show loading state
    this.showLoading()

    // Calls the backend endpoint
    fetch(`${this.searchUrl}?query=${encodeURIComponent(query)}`, {
      headers: { 
        "Accept": "application/json",
        "X-Requested-With": "XMLHttpRequest"
      }
    })
    .then(response => {
      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`)
      }
      return response.json()
    })
    .then(data => {
      this.isLoading = false
      this.renderResults(data)
    })
    .catch(error => {
      this.isLoading = false
      console.error("Error fetching CPT codes:", error)
      this.renderError()
    })
  }

  showLoading() {
    this.isLoading = true
    this.resultsTarget.innerHTML = `
      <li class="p-3 text-gray-500 text-sm flex items-center">
        <svg class="animate-spin -ml-1 mr-2 h-4 w-4 text-indigo-500" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
          <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
          <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
        </svg>
        Searching...
      </li>
    `
    this.showResults()
  }

  renderResults(data) {
    // Reset selection index
    this.selectedIndex = -1
    
    if (data.length === 0) {
      this.resultsTarget.innerHTML = `
        <li class="p-3 text-gray-500 text-sm">
          No results found
        </li>
      `
    } else {
      this.resultsTarget.innerHTML = data.map((cpt, index) => `
        <li class="cursor-pointer select-none relative py-2 pl-3 pr-9 hover:bg-indigo-600 hover:text-white group"
            data-action="click->cpt-search#select"
            data-code="${this.escapeHtml(cpt.code)}"
            data-name="${this.escapeHtml(cpt.description)}"
            data-index="${index}"
            role="option"
            aria-selected="false">
            
          <div class="flex items-center">
            <span class="font-bold mr-2 group-hover:text-white text-gray-900">
              ${this.escapeHtml(cpt.code)}
            </span>
            <span class="text-gray-500 truncate group-hover:text-indigo-200">
              ${this.escapeHtml(cpt.description)}
            </span>
          </div>
        </li>
      `).join("")
    }
    
    this.showResults()
  }

  renderError() {
    this.resultsTarget.innerHTML = `
      <li class="p-3 text-red-500 text-sm">
        Error loading results. Please try again.
      </li>
    `
    this.showResults()
  }

  // Triggered when clicking a dropdown item
  select(event) {
    const item = event.target.closest("li")
    if (item) {
      this.selectItem(item)
    }
  }

  selectItem(item) {
    const code = item.dataset.code
    const name = item.dataset.name
    
    // Updates the visible input so the user sees what they picked
    this.inputTarget.value = `${code} - ${name}`
    
    // Updates the hidden fields (This is what actually submits to Rails)
    if (this.hasHiddenCodeFieldTarget) {
      this.hiddenCodeFieldTarget.value = code
    }
    if (this.hasHiddenNameFieldTarget) {
      this.hiddenNameFieldTarget.value = name
    }
    
    // Hides the dropdown
    this.hideResults()
    
    // Dispatch custom event for other controllers to listen to
    this.dispatch("selected", { 
      detail: { code, name },
      bubbles: true 
    })
  }

  showResults() {
    this.resultsTarget.classList.remove("hidden")
    this.resultsTarget.setAttribute("aria-expanded", "true")
  }

  hideResults() {
    this.resultsTarget.classList.add("hidden")
    this.resultsTarget.setAttribute("aria-expanded", "false")
    this.selectedIndex = -1
  }

  // Escape HTML to prevent XSS
  escapeHtml(text) {
    const div = document.createElement("div")
    div.textContent = text
    return div.innerHTML
  }

  // Clear the input and hidden fields
  clear() {
    this.inputTarget.value = ""
    if (this.hasHiddenCodeFieldTarget) {
      this.hiddenCodeFieldTarget.value = ""
    }
    if (this.hasHiddenNameFieldTarget) {
      this.hiddenNameFieldTarget.value = ""
    }
    this.hideResults()
  }
}
