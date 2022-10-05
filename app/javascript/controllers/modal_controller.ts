import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["dialog", "openOnLoad"]

  declare hasDialogTarget: boolean
  declare hasOpenOnLoadTarget: boolean
  declare dialogTarget: HTMLElement

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
      document.body.classList.add("no-scroll")
    }
  }

  close(e?: MouseEvent) {
    if (e) {
      e.stopPropagation()
      e.preventDefault()
    }
    this.element.classList.remove("visible")
    this.element.setAttribute("aria-hidden", "true")
    document.body.classList.remove("no-scroll")
  }

  closeAndContinue(e: MouseEvent) {
    this.close()
  }

  closeBackground(e) {
    if (e && (!this.inDocument(e.target) || this.inModal(e.target)) || !this.modalVisible()) {
      return
    }
    this.close()
  }

  inDocument(target_element) {
    return document.contains(target_element)
  }

  inModal(target_element) {
    return this.dialogTarget.contains(target_element)
  }

  modalVisible() {
    return this.element.classList.contains("visible")
  }
}
