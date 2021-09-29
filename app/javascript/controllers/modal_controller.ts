import { Controller } from "stimulus"

export default class extends Controller {
  static targets = ["dialog", "openOnLoad"]
  declare dialogTarget: Element
  declare dialogTargets: Element[]
  declare hasDialogTarget: boolean
  declare hasOpenOnLoadTarget: boolean

  connect() {
    if (this.hasOpenOnLoadTarget) {
      this.open()
    }
  }

  open() {
    if (this.hasDialogTarget) {
      this.element.classList.add("visible")
      this.element.setAttribute("aria-hidden", "false")
    }
  }

  close(e: MouseEvent) {
    e.preventDefault()
    e.stopPropagation()

    if (this.hasDialogTarget) {
      this.element.classList.remove("visible")
      this.element.setAttribute("aria-hidden", "true")
    }
  }
}
