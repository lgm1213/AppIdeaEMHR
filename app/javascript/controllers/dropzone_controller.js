import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "submit"]

  connect() {
    this.element.addEventListener("dragover", this.preventDefaults)
    this.element.addEventListener("dragenter", this.highlight)
    this.element.addEventListener("dragleave", this.unhighlight)
    this.element.addEventListener("drop", this.handleDrop)
  }

  disconnect() {
    this.element.removeEventListener("dragover", this.preventDefaults)
    this.element.removeEventListener("dragenter", this.highlight)
    this.element.removeEventListener("dragleave", this.unhighlight)
    this.element.removeEventListener("drop", this.handleDrop)
  }

  preventDefaults = (e) => {
    e.preventDefault()
    e.stopPropagation()
  }

  highlight = () => {
    this.element.classList.add("border-indigo-500", "bg-indigo-50")
  }

  unhighlight = () => {
    this.element.classList.remove("border-indigo-500", "bg-indigo-50")
  }

  handleDrop = (e) => {
    this.preventDefaults()
    this.unhighlight()
    
    const dt = e.dataTransfer
    const files = dt.files
    
    this.inputTarget.files = files
    this.submitForm()
  }

  browse() {
    this.inputTarget.click()
  }

  upload() {
    // This was empty before! That's why "Click to Select" did nothing.
    this.submitForm()
  }

  submitForm() {
    // Manually trigger the hidden submit button
    this.submitTarget.click()
  }
}