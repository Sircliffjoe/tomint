import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["select", "editor"]

  connect() {
    console.log("Page template controller connected")
    this.templates = {
      contact: `<div>We'd love to hear from you. Reach out through any of the channels below.</div>`,
      privacy: `<div>
        <h2>Privacy Policy</h2>
        <p>Your privacy is important to us. This policy explains how Teenagers' Outreach Ministries (TOM) Inc. collects, uses, and protects your personal information.</p>
        <h3>Information We Collect</h3>
        <p>We collect information you provide when registering for events, signing up for an account, or contacting us.</p>
        <h3>How We Use Your Information</h3>
        <p>We use your information solely to provide our services, communicate with you about events, and improve our ministry outreach.</p>
      </div>`,
      terms: `<div>
        <h2>Terms of Service</h2>
        <p>By using the TOM International website and services, you agree to these terms and conditions.</p>
        <h3>Use of Service</h3>
        <p>This website is provided for informational purposes and to facilitate event registrations and ministry activities.</p>
        <h3>Account Responsibility</h3>
        <p>You are responsible for maintaining the confidentiality of your account credentials.</p>
      </div>`
    }
  }

  change() {
    console.log("Template changed to:", this.selectTarget.value)
    const template = this.selectTarget.value
    const content = this.templates[template]

    if (content && this.hasEditorTarget) {
      const editor = this.editorTarget.editor
      if (editor && editor.getDocument().toString().trim() === "") {
        editor.loadHTML(content)
      }
    }
  }
}

