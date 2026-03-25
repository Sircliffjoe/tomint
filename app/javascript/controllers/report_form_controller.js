import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["categorySelect", "section", "incomeInput", "programmeInput", "adminInput", "obligationInput", "totalIncome", "totalProgramme", "totalAdmin", "totalObligation", "closingBalance"]

  connect() {
    console.log("Report form controller connected")
    this.element.classList.add("report-form--connected")
    this.updateSections()
  }

  updateSections() {
    const select = this.categorySelectTarget
    const categoryName = select.options[select.selectedIndex]?.text?.trim()
    console.log("Category selected (trimmed):", categoryName)

    const mapping = {
      "Annual Report": ["clubs", "programmes", "seminars", "meetings", "external_engagements", "financial_summary", "others"],
      "Camp Report": ["programmes", "detailed_financial", "others"],
      "Training Report": ["seminars"],
      "Financial Report": ["detailed_financial"]
    }

    const activeSections = mapping[categoryName] || []
    console.log("Active sections for", categoryName, ":", activeSections)

    this.sectionTargets.forEach(section => {
      const templateName = section.dataset.template
      if (activeSections.includes(templateName)) {
        section.classList.remove("hidden")
      } else {
        section.classList.add("hidden")
      }
    })
  }

  calculateFinancial() {
    const sum = (selectors) => {
      return Array.from(selectors).reduce((acc, input) => acc + (parseFloat(input.value) || 0), 0)
    }

    const totalIncome = sum(this.incomeInputTargets)
    const totalProgramme = sum(this.programmeInputTargets)
    const totalAdmin = sum(this.adminInputTargets)
    const totalObligation = sum(this.obligationInputTargets)

    if (this.hasTotalIncomeTarget) this.totalIncomeTarget.value = totalIncome
    if (this.hasTotalProgrammeTarget) this.totalProgrammeTarget.value = totalProgramme
    if (this.hasTotalAdminTarget) this.totalAdminTarget.value = totalAdmin
    if (this.hasTotalObligationTarget) this.totalObligationTarget.value = totalObligation

    const closingBalance = totalIncome - (totalProgramme + totalAdmin + totalObligation)
    if (this.hasClosingBalanceTarget) this.closingBalanceTarget.value = closingBalance
  }
}
