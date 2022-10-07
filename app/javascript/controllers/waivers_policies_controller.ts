import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["agreement", "signature"]
  declare signatureTarget: HTMLInputElement
  declare agreementTargets: any

  signatureHandler() {
    const unCheckedCheckBoxes = this.agreementTargets.filter(
      (target) => !target.checked
    )

    if (unCheckedCheckBoxes.length > 0) {
      unCheckedCheckBoxes.forEach(this.setError)
      this.signatureTarget.checked = false
    }
  }

  agreementHandler(event) {
    if (event.target.checked) {
      event.target.parentElement.className = "agree"
    } else {
      this.signatureTarget.checked = false
    }
  }

  setError(target: HTMLInputElement) {
    target.parentElement.className = "agree-error"
  }
}
