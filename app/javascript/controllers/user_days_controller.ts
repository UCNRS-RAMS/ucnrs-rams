import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["arrivesAt", "departsAt", "count", "userDays", "output", "outputVal"]
  declare arrivesAtTarget: HTMLInputElement
  declare departsAtTarget: HTMLInputElement
  declare outputValTarget: HTMLInputElement
  declare countTarget: HTMLInputElement
  declare userDaysTarget: HTMLFormElement
  declare outputTarget: HTMLFormElement

  calculate(){
    const userDays = this.days() * parseInt(this.countTarget.value)
    this.outputValTarget.value = userDays.toString()
    this.outputTarget.innerText = `${this.days()} days x ${this.countTarget.value} users = ${userDays} userdays`
  }

  reset(){
    this.outputValTarget.value = null
  }

  countChange(e){
    this.countTarget.value = e.target.value
    this.calculate()
  }

  days() {
    var difference = new Date(this.departsAtTarget.value).getTime() - new Date(this.arrivesAtTarget.value).getTime()
    var totalDays = Math.ceil(difference / (1000 * 3600 * 24)) + 1;
    return totalDays;
  }

  disable() {
    this.outputValTarget.value = null
    this.outputValTarget.setAttribute("disabled", "true" )
  }

  enable() {
    this.outputValTarget.removeAttribute("disabled")
  }
}
