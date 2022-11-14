import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["arriveOn", "departsOn", "days"]

  declare daysTarget: HTMLInputElement
  declare arriveOnTarget: HTMLInputElement
  declare departsOnTarget: HTMLInputElement

  connect(): void {
    this.days()
  }

  days() {
    let difference = new Date(this.departsOnTarget.value).getTime() - new Date(this.arriveOnTarget.value).getTime()
    let totalDays = Math.ceil(difference / (1000 * 3600 * 24)) + 1;
    totalDays = Math.max(totalDays || 1, 1)
    this.daysTarget.innerHTML = totalDays.toString()
    return totalDays;
  }
}
