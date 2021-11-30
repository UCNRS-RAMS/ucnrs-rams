import { Controller } from "@hotwired/stimulus"
import { FrameElement } from "@hotwired/turbo/dist/types/elements"

export default class extends Controller {
  static targets = ["destination"]

  declare destinationTarget: FrameElement
  declare destinationTargets: FrameElement[]

  urlPatternPlaceholder = "VALUE"

  change(e: Event) {
    const value = (e.currentTarget as HTMLInputElement).value
    this.load(value)
  }

  selectedProjectType() {
    const selected = this.element.querySelector('input[type="radio"]:checked')
    if (selected) {
      return (selected as HTMLInputElement).value
    }
  }

  generateUrl(target: FrameElement, query: string) {
    const srcPattern = target.dataset.pattern
    return srcPattern.replace(this.urlPatternPlaceholder, query)
  }

  load(value: string) {
    this.destinationTargets.forEach((target) => target.src = this.generateUrl(target, value))
  }
}
