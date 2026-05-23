import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["dialog"]

  declare dialogTarget: HTMLDialogElement

  connect() {
    document.addEventListener("turbo:before-cache", this.close)
  }

  disconnect() {
    document.removeEventListener("turbo:before-cache", this.close)
  }

  open() {
    this.dialogTarget.showModal()
  }

  close = () => {
    if (this.dialogTarget.open) this.dialogTarget.close()
  }

  closeOnBackdrop(event: MouseEvent) {
    if (event.target === this.dialogTarget) this.close()
  }
}
