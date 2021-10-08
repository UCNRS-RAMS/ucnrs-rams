import { Controller } from "stimulus"

export default class extends Controller {
  static targets = ["needs", "alert"]

  declare needsTarget: HTMLElement
  declare alertTarget: HTMLElement

  change(e: Event) {
    const current = parseInt(this.outputTarget.value) || 0
    this.outputTarget.value = Math.max(current + amount, 0).toString();
  }
}
