import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["rate", "unit", "subTotal", "arrives", "departs", "days", "checkBox"]

  declare subTotalTarget: HTMLElement
  declare unitTarget: HTMLInputElement
  declare daysTarget: HTMLInputElement
  declare arrivesTarget: HTMLInputElement
  declare departsTarget: HTMLInputElement
  declare checkBoxTarget: HTMLInputElement
  declare rateTarget: any

  connect(): void {
      this.calculateSubtotal()
      this.calculateTotal()
  }

  calculateSubtotal() {
    const rate =
      this.rateTarget.options[this.rateTarget.selectedIndex].innerText.match(
        /\d+/
      )[0]

    const subtotal = (
      this.unit() *
      parseFloat(rate) *
      this.days()
    ).toFixed(2)

    this.subTotalTarget.innerHTML = subtotal
  }

  unit() {
    const unit = Math.max(parseInt(this.unitTarget.value) || 1, 1)
    this.unitTarget.value = unit.toString();
    return unit
  }

  days() {
    let difference = new Date(this.departsTarget.value).getTime() - new Date(this.arrivesTarget.value).getTime()
    let totalDays = Math.ceil(difference / (1000 * 3600 * 24)) + 1;
    totalDays = Math.max(totalDays || 1, 1)
    this.daysTarget.innerHTML = totalDays.toString()
    return totalDays;
  }

  calculateTotal() {
    document.getElementById("total").innerHTML = "$" + Array.from(document.querySelectorAll(".subtotal")).
      reduce((total, arg) => total + parseFloat(arg.innerHTML), 0.0).toFixed(2).toString();
  }

  toggle() {
    this.checkBoxTarget.checked ? this.subTotalTarget.setAttribute("class", "subtotal") : this.subTotalTarget.removeAttribute("class")
    this.calculateTotal()
  }
}
