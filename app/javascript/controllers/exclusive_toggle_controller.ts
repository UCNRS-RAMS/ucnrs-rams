import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["toggle1", "toggle2"]

  declare toggle1Targets: HTMLInputElement[]
  declare toggle2Targets: HTMLInputElement[]

  toggle(e: Event) {
    const target = e.target as HTMLInputElement
    let targetID = target.getAttribute('data-exclusive-toggle-target')

    if (targetID == "toggle1" && target.checked) {
      this.toggle2Targets.forEach(checkbox => checkbox.checked = false)
    }
    else if ( targetID == "toggle2" && target.checked ) {
      this.toggle1Targets.forEach(checkbox => checkbox.checked = false)
    }
  }
}
