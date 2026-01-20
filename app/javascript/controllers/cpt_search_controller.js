import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  // These targets match the 'data-cpt-search-target' attributes in your HTML
  static targets = ["input", "results", "hiddenCodeField", "hiddenNameField"]

  connect() {
    // Clicks outside to close the dropdown
    document.addEventListener("click", (event) => {
      if (!this.element.contains(event.target)) {
        this.resultsTarget.classList.add("hidden")
      }
    })
  }

  // Triggered by 'input' event on the text box
  search() {
    clearTimeout(this.timeout)
    // Debounce: Wait 300ms after user stops typing to save server requests
    this.timeout = setTimeout(() => {
      this.fetchResults()
    }, 300)
  }

  fetchResults() {
    const query = this.inputTarget.value
    
    // Don't search if the input is too short or empty
    if (query.length < 2) {
      this.resultsTarget.classList.add("hidden")
      return
    }

    // Calls the backend endpoint
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
    
    // Show the list
    this.resultsTarget.classList.remove("hidden")
  }

  // Triggered when clicking a dropdown item
  select(event) {
    // Get data from the clicked element
    // Note: used .closest('li') to ensure we grab the data even if user clicked a child span
    const item = event.target.closest("li")
    const code = item.dataset.code
    const name = item.dataset.name
    
    // Updates the visible input so the user sees what they picked
    this.inputTarget.value = `${code} - ${name}`
    
    // Updates the hidden fields (This is what actually submits to Rails)
    this.hiddenCodeFieldTarget.value = code
    this.hiddenNameFieldTarget.value = name
    
    // Hides the dropdown
    this.resultsTarget.classList.add("hidden")
  }
}