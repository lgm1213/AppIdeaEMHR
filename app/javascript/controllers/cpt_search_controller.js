import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "results", "hiddenCodeField"]

  connect() {
    this.clickOutsideHandler = (event) => {
      if (!this.element.contains(event.target)) {
        this.resultsTarget.classList.add("hidden")
      }
    }
    document.addEventListener("click", this.clickOutsideHandler)
  }

  disconnect() {
    document.removeEventListener("click", this.clickOutsideHandler)
  }

  // Copies the visible input value to the hidden field immediately
  sync() {
    this.hiddenCodeFieldTarget.value = this.inputTarget.value
  }

  // Handles the Enter key exclusively for the CPT input.
  // Guaranteed order: 1. Sync data -> 2. Submit form
  commit(event) {
    if (event.key === "Enter") {
      event.preventDefault()
      
      // 1. Force the sync immediately
      this.sync()
      
      // 2. Manually submit the form
      this.element.closest("form").requestSubmit()
    }
  }

  search() {
    this.sync() // Also sync while typing normally
    
    clearTimeout(this.timeout)
    // Debounce: Wait 300ms after user stops typing to save server requests
    this.timeout = setTimeout(() => {
      this.fetchResults()
    }, 300)
  }

  fetchResults() {
    const query = this.inputTarget.value
    
    if (query.length < 2) {
      this.resultsTarget.classList.add("hidden")
      return
    }

    fetch(`/cpt_codes?query=${encodeURIComponent(query)}`, {
      headers: { "Accept": "application/json" }
    })
    .then(response => response.json())
    .then(data => this.renderResults(data))
    .catch(error => console.error("Error fetching CPT codes:", error))
  }

  renderResults(data) {
    if (data.length === 0) {
      this.resultsTarget.innerHTML = `<li class="p-3 text-gray-500 text-sm">No results found</li>`
    } else {
      this.resultsTarget.innerHTML = data.map(cpt => `
        <li class="cursor-pointer select-none relative py-2 pl-3 pr-9 hover:bg-indigo-600 hover:text-white group"
            data-action="click->cpt-search#select"
            data-code="${cpt.code}"
            data-name="${cpt.description}">
            
          <div class="flex items-center">
            <span class="font-bold mr-2 group-hover:text-white text-gray-900">
              ${cpt.code}
            </span>
            <span class="text-gray-500 truncate group-hover:text-indigo-200">
              ${cpt.description}
            </span>
          </div>
        </li>
      `).join("")
    }
    
    this.resultsTarget.classList.remove("hidden")
  }

  select(event) {
    const item = event.target.closest("li")
    const code = item.dataset.code
    const name = item.dataset.name
    
    this.inputTarget.value = `${code} - ${name}`
    this.hiddenCodeFieldTarget.value = code
    this.resultsTarget.classList.add("hidden")
  }
}