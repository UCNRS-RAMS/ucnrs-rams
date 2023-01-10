import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["tagsDiv"]
  declare tagsDivTarget: HTMLDivElement

  connect(): void {
    this.tagsDivTarget.style.display = "none"
  }

  toggle() {
    const display = this.tagsDivTarget.style.display
    this.tagsDivTarget.style.display = display === "none" ? "block" : "none"
  }
}
