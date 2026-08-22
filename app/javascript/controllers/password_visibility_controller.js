import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "eyeIcon", "eyeSlashIcon"]

  toggle(event) {
    if (event) event.preventDefault()
    if (!this.hasInputTarget) return

    const isPassword = this.inputTarget.type === "password"
    this.inputTarget.type = isPassword ? "text" : "password"

    if (this.hasEyeIconTarget && this.hasEyeSlashIconTarget) {
      if (isPassword) {
        // Password is now visible (show eye-slash icon to hide)
        this.eyeIconTarget.classList.add("hidden")
        this.eyeSlashIconTarget.classList.remove("hidden")
      } else {
        // Password is now hidden (show regular eye icon to reveal)
        this.eyeIconTarget.classList.remove("hidden")
        this.eyeSlashIconTarget.classList.add("hidden")
      }
    }
  }
}
