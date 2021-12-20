import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["dialog", "openOnLoad"]

  declare hasDialogTarget: boolean
  declare hasOpenOnLoadTarget: boolean

  connect() {
    this.element[this.identifier] = this
  }

  openOnLoadTargetConnected(e: HTMLElement) {
    this.open()
  }

  open() {
    if (this.hasDialogTarget) {
      this.element.classList.add("visible")
      this.element.setAttribute("aria-hidden", "false")
    }
  }

  close() {
    if (this.hasDialogTarget) {
      this.element.classList.remove("visible")
      this.element.setAttribute("aria-hidden", "true")
    }
  }

  clickClose(e: MouseEvent) {
    e.preventDefault()
    e.stopPropagation()
    this.close()
  }
}
