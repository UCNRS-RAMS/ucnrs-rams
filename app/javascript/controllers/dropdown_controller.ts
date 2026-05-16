import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["dropdown"]

  declare dropdownTarget: HTMLElement

  toggle(e: Event) {
    e.preventDefault()
    this.toggleCSSClass(this.dropdownTarget)
  }

  hide(event: Event) {
    const dropdown = this.dropdownTarget
    const toggleClass = dropdown.dataset.toggleClass ?? ""
    const dropdownClass = dropdown.dataset.dropdownClass ?? ""

    if (!this.element.contains(event.target as Node) && !dropdown.classList.contains(toggleClass)) {
      dropdown.classList.remove(dropdownClass)
    }
  }

  toggleCSSClass(target: HTMLElement) {
    target.classList.toggle(target.dataset.dropdownClass ?? "")
  }
}
