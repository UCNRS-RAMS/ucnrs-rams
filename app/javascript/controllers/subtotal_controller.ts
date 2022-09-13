import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["initialVal", "subtotal", "rate",  "count", "arriveOn", "departsOn", "arriveAt", "departsAt", "unitType"]
  declare countTarget: HTMLInputElement
  declare subtotalTarget: HTMLInputElement
  declare initialValTarget: HTMLInputElement
  declare arriveOnTarget: HTMLInputElement
  declare arriveAtTarget: HTMLInputElement
  declare departsAtTarget: HTMLInputElement
  declare departsOnTarget: HTMLInputElement
  declare unitTypeTarget: HTMLInputElement
  
  connect() {
    this.calculateSubtotal()
  }

  async calculateSubtotal(){
    const units = Math.max(await this.getSubtotal(), 0)
    if (parseFloat(this.countTarget.value) < 1 || this.countTarget.value == '')
      this.countTarget.value = '1'
    this.subtotalTarget.innerText = (parseFloat(this.countTarget.value) * parseFloat(this.initialValTarget.textContent) * parseFloat(units)).toFixed(2)
  }

  setRate(rateValue){
    this.initialValTarget.innerText = rateValue
    this.calculateSubtotal()
 }

  async getSubtotal(){
    const arrive = `${this.arriveOnTarget.value} ${this.arriveAtTarget.value}`
    const departs = `${this.departsOnTarget.value} ${this.departsAtTarget.value}`
    const url = `/visits/units?arrive=${encodeURIComponent(arrive)}&departs=${encodeURIComponent(departs)}&unit=${this.unitTypeTarget.textContent.trim()}`
    return fetch(url,
      { 
        headers: {
          'Content-Type': 'application/json',
        }
      }
    )
    .then((res) => res.json())
    .then((result) => result.data)
  }
}
