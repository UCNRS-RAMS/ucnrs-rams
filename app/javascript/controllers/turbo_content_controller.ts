import { Controller } from "@hotwired/stimulus"
import { FrameElement } from "@hotwired/turbo/dist/types/elements"

export default class extends Controller {
  static targets = ["destination"]

  declare destinationTarget: FrameElement

  urlPatternPlaceholder = "VALUE"

  connect() {
    this.load(this.selectedProjectType())
  }

  change(e: Event) {
    const value = (e.currentTarget as HTMLInputElement).value
    this.load(value)
  }

  selectedProjectType() {
    const selected = this.element.querySelector('input[type="radio"]:checked')
    return (selected as HTMLInputElement).value
  }

  generateUrl(query: string) {
    const srcPattern = this.destinationTarget.dataset.pattern
    return srcPattern.replace(this.urlPatternPlaceholder, query)
  }

  load(value: string) {
    this.destinationTarget.src = this.generateUrl(value)
  }
}
