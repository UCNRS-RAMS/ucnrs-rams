import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["dialog", "openOnLoad"]

  declare hasDialogTarget: boolean
  declare hasOpenOnLoadTarget: boolean
  declare dialogTarget: HTMLElement

  previouslyFocused: HTMLElement | null = null

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
      this.element.removeAttribute("inert")
      document.body.classList.add("no-scroll")
      this.focusDialog()
    }
  }

  close(e?: MouseEvent) {
    if (e) {
      e.stopPropagation()
      e.preventDefault()
    }
    this.element.classList.remove("visible")
    this.element.setAttribute("aria-hidden", "true")
    this.element.setAttribute("inert", "")
    document.body.classList.remove("no-scroll")
    this.restoreFocus()
  }

  closeAndContinue(e: MouseEvent) {
    this.close()
  }

  focusDialog() {
    const active = document.activeElement as HTMLElement | null
    if (active && this.dialogTarget.contains(active)) {
      return
    }
    this.previouslyFocused = active
    this.dialogTarget.setAttribute("tabindex", "-1")
    this.dialogTarget.focus()
  }

  restoreFocus() {
    if (this.previouslyFocused?.isConnected) {
      this.previouslyFocused.focus()
    }
    this.previouslyFocused = null
  }

  closeOnEscape() {
    if (this.modalVisible()) {
      this.close()
    }
  }

  closeBackground(e) {
    if (e && !this.modalVisible()) {
      return
    }
    else if (!this.inDocument(e.target) || this.inModal(e.target)) {
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
