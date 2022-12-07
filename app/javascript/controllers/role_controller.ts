import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["advisor", "options"]

  declare advisorTarget: Element
  declare optionsTarget: any

  showAdvisorField(event: Event) {

    if (this.optionsTarget.value.includes(event.currentTarget.firstElementChild.value)) {
      this.advisorTarget.className = "field large"
    } else {
      this.advisorTarget.className = "no-field"
    }
  }
}
