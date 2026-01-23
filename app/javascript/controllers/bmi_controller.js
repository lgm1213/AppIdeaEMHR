// app/javascript/controllers/bmi_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["height", "weight", "output"]

  connect() {
    console.log("BMI Controller Connected!")
  }

  calculate() {
    const height = parseFloat(this.heightTarget.value)
    const weight = parseFloat(this.weightTarget.value)

    // Formula: (Weight in lbs * 703) / (Height in inches)^2
    if (height > 0 && weight > 0) {
      const bmi = (weight * 703) / (height * height)
      this.outputTarget.textContent = bmi.toFixed(1)
      
      // Optional: Add visual color coding based on range
      this.colorize(bmi)
    } else {
      this.outputTarget.textContent = "--"
      this.outputTarget.className = "mt-1 px-3 py-2 bg-gray-100 border border-gray-200 rounded-md text-gray-600 sm:text-sm"
    }
    console.log("Calculating...")
  }

  colorize(bmi) {
    let colorClass = "bg-gray-100 text-gray-800" // Normal/Default
    
    if (bmi < 18.5) colorClass = "bg-blue-100 text-blue-800"      // Underweight
    if (bmi >= 25 && bmi < 30) colorClass = "bg-yellow-100 text-yellow-800" // Overweight
    if (bmi >= 30) colorClass = "bg-red-100 text-red-800"         // Obese

    // Reset classes and apply new ones
    this.outputTarget.className = `mt-1 px-3 py-2 border border-gray-200 rounded-md sm:text-sm ${colorClass}`
  }
}