import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["destination"]

  declare destinationTargets: HTMLInputElement[]

  copy(e: Event) {
    const source = e.currentTarget as HTMLInputElement
    this.destinationTargets.forEach(target => target.value = source.value || source.textContent)
  }
}
