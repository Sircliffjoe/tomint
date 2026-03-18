import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "priceField", "currencyField" ]

  connect() {
    this.togglePrice()
  }

  togglePrice(event) {
    const eventType = event ? event.target.value : this.element.querySelector('select[name="event[event_type]"]').value
    
    if (eventType === 'paid') {
      this.priceFieldTarget.classList.remove('hidden')
      this.currencyFieldTarget.classList.remove('hidden')
    } else {
      this.priceFieldTarget.classList.add('hidden')
      this.currencyFieldTarget.classList.add('hidden')
    }
  }
}
