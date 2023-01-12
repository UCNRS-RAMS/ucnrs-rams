import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form", "tagsDiv"]
  declare formTarget: HTMLFormElement
  declare tagsDivTargets: any

  reset() {
    this.formTarget.reset()
    this.tagsDivTargets.forEach(this.hideTagNames)
    this.formTarget.requestSubmit()
  }

  hideTagNames = (element: HTMLDivElement) => {
    element.style.display = "none"
  }
}
