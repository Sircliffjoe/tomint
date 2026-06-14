import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "priceField", "currencyField" ]

  connect() {
    this.togglePrice()
  }

  togglePrice(event) {
    const eventType = event ? event.target.value : this.element.querySelector('select[name="event[event_type]"]').value
    const priceInputs = this.priceFieldTarget.querySelectorAll("input, select, textarea")
    const currencyInputs = this.currencyFieldTarget.querySelectorAll("input, select, textarea")
    
    if (eventType === 'paid') {
      this.priceFieldTarget.classList.remove('hidden')
      this.currencyFieldTarget.classList.remove('hidden')
      priceInputs.forEach((input) => input.disabled = false)
      currencyInputs.forEach((input) => input.disabled = false)
    } else {
      this.priceFieldTarget.classList.add('hidden')
      this.currencyFieldTarget.classList.add('hidden')
      priceInputs.forEach((input) => input.disabled = true)
      currencyInputs.forEach((input) => input.disabled = true)
    }
  }
}
