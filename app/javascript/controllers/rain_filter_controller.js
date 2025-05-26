import { Controller } from "@hotwired/stimulus"
console.log("RainFilterController loaded")
export default class extends Controller {
  static targets = ["checkbox", "indicator", "badge"]

  connect() {
    // Initialize the indicator state based on checkbox
    this.toggleIndicator()
  }

  toggleIndicator() {
    const isChecked = this.checkboxTarget.checked
    
    // Toggle the star indicator
    if (isChecked) {
      this.indicatorTarget.classList.remove("hidden")
      this.badgeTarget.classList.remove("hidden")
    } else {
      this.indicatorTarget.classList.add("hidden")
      this.badgeTarget.classList.add("hidden")
    }
  }
} 