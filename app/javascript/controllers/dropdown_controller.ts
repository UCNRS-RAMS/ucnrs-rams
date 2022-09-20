import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["dropdown"]

  declare dropdownTarget: HTMLElement

  toggle(e: Event) {
    e.preventDefault()
    this.toggleCSSClass(this.dropdownTarget)
  }

  hide(event) {
    if (!this.element.contains(event.target) && !this.dropdownTarget.classList.contains(this.dropdownTarget.dataset.toggleClass)) {
      this.dropdownTarget.classList.remove(this.dropdownTarget.dataset.dropdownClass)
    }
  }

  toggleCSSClass(target) {
    target.classList.toggle(target.dataset.dropdownClass)
  }
}
