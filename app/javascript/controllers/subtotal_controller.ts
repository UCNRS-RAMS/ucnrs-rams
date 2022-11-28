import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["initialVal", "subtotal", "rate",  "count", "arriveOn", "departsOn", "arriveAt", "departsAt", "unitType", "checkBox" ]
  declare countTarget: HTMLInputElement
  declare subtotalTarget: HTMLInputElement
  declare initialValTarget: any
  declare arriveOnTarget: HTMLInputElement
  declare arriveAtTarget: HTMLInputElement
  declare departsAtTarget: HTMLInputElement
  declare departsOnTarget: HTMLInputElement
  declare unitTypeTarget: HTMLInputElement
  declare checkBoxTarget: HTMLInputElement
  
  async connect() {
   await this.calculateSubtotal()
  }

  checkBoxTargetConnected(){
    this.calculateTotal()
  }

  async calculateSubtotal(){
    const units = Math.max(await this.getSubtotal(), 0);
    const rate = this.rate()
    if (parseFloat(this.countTarget.value) < 1 || this.countTarget.value == '')
      this.countTarget.value = '1'
    this.subtotalTarget.innerText = (parseFloat(this.countTarget.value) * parseFloat(rate) * parseFloat(units)).toFixed(2)
    this.calculateTotal()
  }

  setRate(rateValue){
    this.initialValTarget.innerText = rateValue
    this.calculateSubtotal()
 }

  async getSubtotal(){
    const arrives = `${this.arriveOnTarget.value} ${this.arriveAtTarget.value}`
    const departs = `${this.departsOnTarget.value} ${this.departsAtTarget.value}`
    return await this.fetchSubtotal(arrives, departs)
  }

  async fetchSubtotal(arrives, departs){
    const url = `/visits/units?arrive=${encodeURIComponent(arrives)}&departs=${encodeURIComponent(departs)}&unit=${this.unitTypeTarget.textContent.trim()}`
    return fetch(url,
      { 
        headers: {
          'Content-Type': 'application/json',
        }
      }
    )
    .then((res) => res.json())
    .then((result) => result.data)
    .catch((e)=> console.log(`Something went wrong. Error ${e}`))
  }

  rate() {
    if (this.initialValTarget.type == 'select-one') {
      return this.initialValTarget.options[this.initialValTarget.selectedIndex].innerText.match(/\d+/)[0]
    } else {
      return this.initialValTarget.textContent
    }
  }
  
  calculateTotal() {
    let subtotal
    if (document.getElementById('total') != null)
      subtotal = Array.from(document.querySelectorAll('.subtotal')).
        reduce((total, arg) => total + parseFloat(arg.innerHTML), 0.0).toFixed(2).toString();
      document.getElementById('total').innerHTML = '$' + subtotal
      document.getElementById('balance_due').value = subtotal
  }

  toggle() {
    this.checkBoxTarget.checked ? this.subtotalTarget.setAttribute('class', 'subtotal') : this.subtotalTarget.removeAttribute('class')
    this.calculateTotal()
  }
}
