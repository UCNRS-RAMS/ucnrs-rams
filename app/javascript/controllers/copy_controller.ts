import { Controller } from "@hotwired/stimulus"
import { ElementAccessChain } from "typescript"

export default class extends Controller {
  static targets = ["destination"]

  declare destinationTargets: HTMLInputElement[]

  copy(e: Event) {
    const source = e.currentTarget as HTMLInputElement

    this.destinationTargets.forEach(target => target.value = source.dataset.copyLabel || source.value || source.textContent.trim())
  }
}
