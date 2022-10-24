import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["advisor"]

  declare advisorTarget: Element

  showAdvisorField(event: Event) {
    const options = [
      "research_scientist",
      "research_assistant",
      "graduate_student",
      "undergraduate_student",
    ]

    if (options.includes(event.currentTarget.firstElementChild.value)) {
      this.advisorTarget.className = "field large"
    } else {
      this.advisorTarget.className = "no-field"
    }
  }
}
