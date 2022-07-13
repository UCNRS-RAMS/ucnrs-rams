import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["initialVal", "subtotal", "count"]
  declare countTarget: HTMLInputElement
  declare subtotalTarget: HTMLInputElement
  declare initialValTarget: HTMLInputElement

  calculateSubtotal(){
    if (parseFloat(this.countTarget.value) < 1 || this.countTarget.value == '')
      this.countTarget.value = '1'
    this.subtotalTarget.innerText = (parseFloat(this.countTarget.value) * parseFloat(this.initialValTarget.textContent)).toFixed(2)
  }
}
