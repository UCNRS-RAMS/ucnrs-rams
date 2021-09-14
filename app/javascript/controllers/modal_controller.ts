import { Controller } from "stimulus"

export default class extends Controller {
  static targets = ["dialog"]
  declare dialogTarget: Element
  declare dialogTargets: Element[]
  declare hasDialogTarget: boolean

  connect() {
    this.open()
  }

  open() {
    if (this.hasDialogTarget) {
      this.element.classList.add("visible")
      this.element.setAttribute("aria-hidden", "false")
      document
        .getElementsByTagName("main")[0]
        .setAttribute("aria-hidden", "true")
    }
  }

  close() {
    if (this.hasDialogTarget) {
      this.element.classList.remove("visible")
      this.element.setAttribute("aria-hidden", "true")
      document
        .getElementsByTagName("main")[0]
        .setAttribute("aria-hidden", "false")
    }
  }
}
