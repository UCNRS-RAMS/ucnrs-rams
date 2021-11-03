import { Controller } from "@hotwired/stimulus"
import { FrameElement } from "@hotwired/turbo/dist/types/elements"

export default class extends Controller {
  static targets = ["destination"]

  declare destinationTarget: FrameElement

  urlPatternPlaceholder = "VALUE"

  connect() {
    const selectedProjectType = document.querySelectorAll('input[type="radio"]:checked')
    if (selectedProjectType.length == 0) return

    const radioValue = (selectedProjectType[0] as HTMLInputElement).value
    this.generateUrl(radioValue)
    this.reloadFrame()
  }

  change(e: Event) {
    const value = (e.currentTarget as HTMLInputElement).value
    this.generateUrl(value)
    this.reloadFrame()
  }

  generateUrl(query: string) {
    const srcPattern = this.destinationTarget.dataset.pattern
    this.destinationTarget.src = srcPattern.replace(this.urlPatternPlaceholder, query)
  }

  reloadFrame() {
    this.destinationTarget.reload()
  }
}
