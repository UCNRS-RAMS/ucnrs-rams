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

  openOnLoadTargetDisconnected(e: HTMLElement) {
    this.close()
  }

  open() {
    if (this.hasDialogTarget) {
      this.element.classList.add("visible")
      this.element.setAttribute("aria-hidden", "false")
    }
  }

  close(e?: MouseEvent) {
    if (e) {
      e.stopPropagation()
      e.preventDefault()
    }
    this.element.classList.remove("visible")
    this.element.setAttribute("aria-hidden", "true")
  }

  closeAndContinue(e: MouseEvent) {
    this.close()
  }
}
