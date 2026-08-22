import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["panel", "button", "openIcon", "closeIcon", "badge"]

  toggle(event) {
    if (event) event.preventDefault()
    if (!this.hasPanelTarget) return

    const isHidden = this.panelTarget.classList.contains("hidden")
    if (isHidden) {
      this.open()
    } else {
      this.close()
    }
  }

  open() {
    if (!this.hasPanelTarget) return
    this.panelTarget.classList.remove("hidden")
    if (this.hasOpenIconTarget && this.hasCloseIconTarget) {
      this.openIconTarget.classList.add("hidden")
      this.closeIconTarget.classList.remove("hidden")
    }
    if (this.hasBadgeTarget) {
      this.badgeTarget.classList.add("hidden")
    }
    // Auto focus question input if present
    const textarea = this.panelTarget.querySelector("textarea")
    if (textarea) {
      setTimeout(() => textarea.focus(), 100)
    }
  }

  close() {
    if (!this.hasPanelTarget) return
    this.panelTarget.classList.add("hidden")
    if (this.hasOpenIconTarget && this.hasCloseIconTarget) {
      this.openIconTarget.classList.remove("hidden")
      this.closeIconTarget.classList.add("hidden")
    }
  }
}
