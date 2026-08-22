import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "step",
    "stepIndicator",
    "bodyInput",
    "charCount",
    "categoryCard",
    "categoryInput",
    "responseChoice",
    "responseChoiceInput",
    "contactSection",
    "contactMethodInput",
    "contactDetailsInput",
    "contactLabel",
    "nextButton",
    "prevButton",
    "submitButton"
  ]

  connect() {
    this.currentStep = 1
    this.totalSteps = 4
    this.showStep(this.currentStep)
    this.updateCharCount()
  }

  showStep(stepNumber) {
    this.stepTargets.forEach((el, index) => {
      if (index + 1 === stepNumber) {
        el.classList.remove("hidden")
        el.style.display = "block"
      } else {
        el.classList.add("hidden")
        el.style.display = "none"
      }
    })

    this.stepIndicatorTargets.forEach((el, index) => {
      if (index + 1 === stepNumber) {
        el.classList.add("bg-emerald-600", "text-white", "ring-4", "ring-emerald-100")
        el.classList.remove("bg-gray-100", "text-gray-500", "bg-emerald-100", "text-emerald-800")
      } else if (index + 1 < stepNumber) {
        el.classList.add("bg-emerald-100", "text-emerald-800")
        el.classList.remove("bg-emerald-600", "text-white", "ring-4", "ring-emerald-100", "bg-gray-100", "text-gray-500")
      } else {
        el.classList.add("bg-gray-100", "text-gray-500")
        el.classList.remove("bg-emerald-600", "text-white", "ring-4", "ring-emerald-100", "bg-emerald-100", "text-emerald-800")
      }
    })

    if (this.hasPrevButtonTarget) {
      if (stepNumber === 1) {
        this.prevButtonTarget.classList.add("hidden")
        this.prevButtonTarget.style.display = "none"
      } else {
        this.prevButtonTarget.classList.remove("hidden")
        this.prevButtonTarget.style.display = "inline-flex"
      }
    }

    if (this.hasNextButtonTarget && this.hasSubmitButtonTarget) {
      if (stepNumber === this.totalSteps) {
        this.nextButtonTarget.classList.add("hidden")
        this.nextButtonTarget.style.display = "none"
        this.submitButtonTarget.classList.remove("hidden")
        this.submitButtonTarget.style.display = "inline-flex"
      } else {
        this.nextButtonTarget.classList.remove("hidden")
        this.nextButtonTarget.style.display = "inline-flex"
        this.submitButtonTarget.classList.add("hidden")
        this.submitButtonTarget.style.display = "none"
      }
    }
  }

  next(event) {
    if (event) {
      event.preventDefault()
      event.stopPropagation()
    }

    if (this.currentStep === 1) {
      const val = this.hasBodyInputTarget ? this.bodyInputTarget.value.trim() : ""
      if (!val || val.length < 5) {
        if (this.hasBodyInputTarget) {
          this.bodyInputTarget.focus()
          this.bodyInputTarget.classList.add("border-red-400", "ring-2", "ring-red-200")
        }
        return
      }
      if (this.hasBodyInputTarget) {
        this.bodyInputTarget.classList.remove("border-red-400", "ring-2", "ring-red-200")
      }
    }

    if (this.currentStep < this.totalSteps) {
      this.currentStep++
      this.showStep(this.currentStep)
    }
  }

  prev(event) {
    if (event) {
      event.preventDefault()
      event.stopPropagation()
    }

    if (this.currentStep > 1) {
      this.currentStep--
      this.showStep(this.currentStep)
    }
  }

  updateCharCount() {
    if (this.hasBodyInputTarget && this.hasCharCountTarget) {
      const len = this.bodyInputTarget.value.length
      this.charCountTarget.textContent = `${len} ${len === 1 ? 'character' : 'characters'}`

      if (this.bodyInputTarget.value.trim().length >= 5) {
        this.bodyInputTarget.classList.remove("border-red-400", "ring-2", "ring-red-200")
      }
    }
  }

  selectCategory(event) {
    const card = event.currentTarget
    const categoryId = card.dataset.categoryId

    this.categoryCardTargets.forEach(c => {
      c.classList.remove("border-emerald-600", "bg-emerald-50/70", "ring-2", "ring-emerald-500")
      c.classList.add("border-gray-200", "bg-white")
    })

    card.classList.remove("border-gray-200", "bg-white")
    card.classList.add("border-emerald-600", "bg-emerald-50/70", "ring-2", "ring-emerald-500")

    if (this.hasCategoryInputTarget) {
      this.categoryInputTarget.value = categoryId
    }
  }

  selectResponseChoice(event) {
    const card = event.currentTarget
    const choice = card.dataset.choice

    this.responseChoiceTargets.forEach(c => {
      c.classList.remove("border-emerald-600", "bg-emerald-50/70", "ring-2", "ring-emerald-500")
      c.classList.add("border-gray-200", "bg-white")
    })

    card.classList.remove("border-gray-200", "bg-white")
    card.classList.add("border-emerald-600", "bg-emerald-50/70", "ring-2", "ring-emerald-500")

    if (this.hasResponseChoiceInputTarget) {
      this.responseChoiceInputTarget.value = choice
    }

    if (this.hasContactSectionTarget) {
      if (choice === "private_response" || choice === "need_help") {
        this.contactSectionTarget.classList.remove("hidden")
        this.contactSectionTarget.style.display = "block"
      } else {
        this.contactSectionTarget.classList.add("hidden")
        this.contactSectionTarget.style.display = "none"
      }
    }
  }

  selectContactMethod(event) {
    const method = event.target.value
    if (this.hasContactLabelTarget && this.hasContactDetailsInputTarget) {
      if (method === "whatsapp" || method === "phone") {
        this.contactLabelTarget.textContent = "Your WhatsApp or phone number (optional):"
        this.contactDetailsInputTarget.placeholder = "e.g. 08012345678"
      } else if (method === "email") {
        this.contactLabelTarget.textContent = "Your email address (optional):"
        this.contactDetailsInputTarget.placeholder = "e.g. yourname@example.com"
      } else {
        this.contactLabelTarget.textContent = "Your preferred contact details (optional):"
        this.contactDetailsInputTarget.placeholder = "Contact info..."
      }
    }
  }
}
