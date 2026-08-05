import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["toggle", "authenticated"]

  declare toggleTargets: HTMLElement[]
  declare authenticatedTarget: HTMLInputElement
  declare hasAuthenticatedTarget: boolean

  toggle(e: Event) {
    e.preventDefault()

    this.toggleTargets.forEach(target => {
      this.toggleCSSClass(target)
    })
  }

  markUnauthenticated() {
    if (this.hasAuthenticatedTarget) {
      this.authenticatedTarget.value = "false"
    }
  }

  toggleCSSClass(target) {
    target.classList.toggle(target.dataset.toggleClass)
  }
}
