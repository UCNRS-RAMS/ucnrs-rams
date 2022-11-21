import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["arriveOn", "departsOn", "days", "checkBox", "subtotal"]

  declare daysTarget: HTMLInputElement
  declare arriveOnTarget: HTMLInputElement
  declare departsOnTarget: HTMLInputElement
  declare checkBoxTarget: HTMLInputElement
  declare subtotalTarget: HTMLInputElement

  connect(): void {
    this.days()
    this.check()
  }

  check() {
    if (!this.checkBoxTarget.checked){
      this.subtotalTarget.removeAttribute('class')
    }
  }

  days() {
    let difference = new Date(this.departsOnTarget.value).getTime() - new Date(this.arriveOnTarget.value).getTime()
    let totalDays = Math.ceil(difference / (1000 * 3600 * 24)) + 1;
    totalDays = Math.max(totalDays || 1, 1)
    this.daysTarget.innerHTML = totalDays.toString()
    return totalDays;
  }
}
