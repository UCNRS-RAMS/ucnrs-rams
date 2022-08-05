import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["initialVal", "subtotal", "count", "arriveOn", "departsOn", "arriveAt", "departsAt", "unitType"]
  declare countTarget: HTMLInputElement
  declare subtotalTarget: HTMLInputElement
  declare initialValTarget: HTMLInputElement
  declare arriveOnTarget: HTMLInputElement
  declare arriveAtTarget: HTMLInputElement
  declare departsAtTarget: HTMLInputElement
  declare departsOnTarget: HTMLInputElement
  declare unitTypeTarget: HTMLInputElement

  async calculateSubtotal(){
    const units = Math.max(await this.getSubtotal(), 0)
    if (parseFloat(this.countTarget.value) < 1 || this.countTarget.value == '')
      this.countTarget.value = '1'
    this.subtotalTarget.innerText = (parseFloat(this.countTarget.value) * parseFloat(this.initialValTarget.textContent) * parseFloat(units)).toFixed(2)
  }

  async getSubtotal(){
    const arrive = `${this.arriveOnTarget.value} ${this.arriveAtTarget.value}`
    const departs = `${this.departsOnTarget.value} ${this.departsAtTarget.value}`
    const url = `/visits/units?arrive=${encodeURIComponent(arrive)}&departs=${encodeURIComponent(departs)}&unit=${this.unitTypeTarget.innerText.trim()}`
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
