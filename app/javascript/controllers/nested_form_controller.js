import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["target", "template"]

  add(e) {
    e.preventDefault()
    const content = this.templateTarget.innerHTML.replace(/NEW_RECORD/g, new Date().getTime())
    this.targetTarget.insertAdjacentHTML('beforeend', content)
  }

  remove(e) {
    e.preventDefault()
    const wrapper = e.target.closest(".nested-form-wrapper")
    
    // If it's a new unsaved row, just delete it from HTML
    if (wrapper.dataset.newRecord === "true") {
      wrapper.remove()
    } else {
      // If it's an existing DB record, hide it and mark for deletion
      wrapper.style.display = 'none'
      wrapper.querySelector("input[name*='_destroy']").value = 1
    }
  }

  saveOnEnter(e) {
    if (e.key === "Enter") {
      e.preventDefault()
      this.element.closest("form").requestSubmit()
    }
  }
}