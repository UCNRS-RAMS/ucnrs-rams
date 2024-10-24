import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["tagsDiv", "tagCheckBox"]
  declare tagsDivTarget: HTMLDivElement

  connect(): void {
    this.tagsDivTarget.style.display = "none"
  }

  toggle(event: Event): void {
    if (!this.tagsDivTarget.checked) {
      this.resetNamedTags()
    }
    const display = this.tagsDivTarget.style.display
    this.tagsDivTarget.style.display = display === "none" ? "block" : "none"
  }

  resetNamedTags() {
    let checkboxes = this.tagsDivTarget.querySelectorAll("input[type=checkbox]")
    checkboxes.forEach((checkbox) => {
      checkbox.checked = false
    })

    this.tagsDivTarget.querySelector("input").form.requestSubmit()
  }
}
