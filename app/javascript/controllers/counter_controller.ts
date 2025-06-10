import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["output"]
  declare outputTarget: HTMLInputElement

  increment() {
    this.change(1)
  }

  decrement() {
    this.change(-1)
  }

  change(amount: number) {
    const current = parseInt(this.outputTarget.value) || 0
    const maxValue = parseInt(this.outputTarget.max) || Infinity

    if (Math.max(current + amount, 1) <= maxValue) {
      this.outputTarget.value = Math.max(current + amount, 1).toString();
    }
  }
}
