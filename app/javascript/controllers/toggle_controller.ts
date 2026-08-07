import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["toggle"]

  declare toggleTargets: HTMLElement[]

  toggle(e: Event) {
    e.preventDefault()

    this.toggleTargets.forEach(target => {
      this.toggleCSSClass(target)
    })
  }

  toggleCSSClass(target) {
    target.classList.toggle(target.dataset.toggleClass)
  }
}
