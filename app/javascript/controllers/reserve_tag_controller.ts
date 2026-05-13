import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["tagsDiv", "tagCheckBox"]
  declare tagsDivTarget: HTMLDivElement
  declare tagCheckBoxTarget: HTMLInputElement

  connect(): void {
    this.tagsDivTarget.style.display = "none"
  }

  toggle(): void {
    if (!this.tagCheckBoxTarget.checked) {
      this.resetNamedTags()
    }
    const display = this.tagsDivTarget.style.display
    this.tagsDivTarget.style.display = display === "none" ? "block" : "none"
  }

  resetNamedTags() {
    let checkboxes = this.tagsDivTarget.querySelectorAll<HTMLInputElement>("input[type=checkbox]")
    checkboxes.forEach((checkbox) => {
      checkbox.checked = false
    })

    this.tagsDivTarget.querySelector<HTMLInputElement>("input")?.form?.requestSubmit()
  }
}
