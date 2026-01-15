import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal", "slide", "counter"]
  static classes = ["hidden"]
  
  connect() {
    this.index = 0
    // Listen for keyboard events (Escape to close, Arrows to nav)
    document.addEventListener("keydown", this.handleKeydown)
  }

  disconnect() {
    document.removeEventListener("keydown", this.handleKeydown)
  }

  // --- MODAL ACTIONS ---

  open(event) {
    event.preventDefault()
    
    // Get the index from the clicked element (e.g., data-index="2")
    const requestedIndex = event.currentTarget.dataset.index
    this.index = parseInt(requestedIndex) || 0
    
    this.showCurrentSlide()
    this.modalTarget.classList.remove("hidden")
    document.body.style.overflow = "hidden" // Prevent background scrolling
  }

  close(event) {
    if (event) event.preventDefault()
    this.modalTarget.classList.add("hidden")
    document.body.style.overflow = "auto" // Restore scrolling
  }

  // --- NAVIGATION ACTIONS ---

  next(event) {
    if (event) event.stopPropagation()
    if (this.index < this.slideTargets.length - 1) {
      this.index++
    } else {
      this.index = 0 // Loop to start
    }
    this.showCurrentSlide()
  }

  previous(event) {
    if (event) event.stopPropagation()
    if (this.index > 0) {
      this.index--
    } else {
      this.index = this.slideTargets.length - 1 // Loop to end
    }
    this.showCurrentSlide()
  }

  // --- HELPERS ---

  showCurrentSlide() {
    this.slideTargets.forEach((slide, i) => {
      // Toggle hidden class based on index match
      if (i === this.index) {
        slide.classList.remove("hidden")
      } else {
        slide.classList.add("hidden")
      }
    })
    
    // Update counter text (e.g. "1 / 5") if target exists
    if (this.hasCounterTarget) {
      this.counterTarget.textContent = `${this.index + 1} / ${this.slideTargets.length}`
    }
  }

  handleKeydown = (e) => {
    if (this.modalTarget.classList.contains("hidden")) return

    if (e.key === "Escape") this.close()
    if (e.key === "ArrowRight") this.next()
    if (e.key === "ArrowLeft") this.previous()
  }
}