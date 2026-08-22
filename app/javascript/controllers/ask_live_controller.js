import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "charCount", "submitBtn", "copyNotification"]

  connect() {
    this.updateCharCount()
  }

  updateCharCount() {
    if (this.hasInputTarget && this.hasCharCountTarget) {
      const len = this.inputTarget.value.length
      this.charCountTarget.textContent = `${len} / 500`
    }
  }

  clearInput() {
    if (this.hasInputTarget) {
      this.inputTarget.value = ""
      this.updateCharCount()
    }
  }

  copyLink(event) {
    const url = event.currentTarget.dataset.url || window.location.href
    navigator.clipboard.writeText(url).then(() => {
      if (this.hasCopyNotificationTarget) {
        this.copyNotificationTarget.classList.remove("hidden")
        setTimeout(() => {
          this.copyNotificationTarget.classList.add("hidden")
        }, 3000)
      }
    })
  }
}
