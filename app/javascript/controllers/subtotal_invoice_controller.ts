import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["initialVal", "subtotal", "rate", "days", "count", "arriveOn", "departsOn", "arriveAt", "departsAt", "unitType", "checkBox", "paymentRow"]
  declare countTarget: HTMLInputElement
  declare subtotalTarget: HTMLInputElement
  declare daysTargets: HTMLInputElement[]
  declare initialValTarget: any
  declare arriveOnTarget: HTMLInputElement
  declare arriveAtTarget: HTMLInputElement
  declare departsAtTarget: HTMLInputElement
  declare departsOnTarget: HTMLInputElement
  declare unitTypeTarget: HTMLInputElement
  declare checkBoxTarget: HTMLInputElement
  declare paymentRowTarget: HTMLInputElement

  connect() {
  }

  checkBoxTargetConnected() {
    this.calculateAll()
  }

  paymentRowTargetConnected() {
    setTimeout(() => {
      this.calculateTotal()
      this.calculateBalance()
    }, 500)
  }

  paymentRowTargetDisconnected() {
    setTimeout(() => {
      this.calculateTotal()
      this.calculateBalance()
    }, 500)
  }

  async calculateAll() {
    const units = Math.max(await this.getSubtotal(), 0);
    const rate = this.rate()

    if (parseFloat(this.countTarget.value) < 1 || this.countTarget.value == '')
      this.countTarget.value = '1'

    this.subtotalTarget.innerText = (parseFloat(this.countTarget.value) * parseFloat(rate) * units).toFixed(2)

    this.calculateTotal()
    this.calculateBalance()
    this.updateDays(units)
  }

  setRate(rateValue) {
    this.initialValTarget.innerText = rateValue
    this.calculateAll()
  }

  getSubtotal() {
    const arrives = `${this.arriveOnTarget.value} ${this.arriveAtTarget.value}`
    const departs = `${this.departsOnTarget.value} ${this.departsAtTarget.value}`

    return this.fetchSubtotal(arrives, departs)
  }

  fetchSubtotal(arrives, departs) {
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
      .catch((e) => console.log(`Something went wrong. Error ${e}`))
  }

  rate() {
    if (this.checkBoxTarget.checked) {
      return this.initialValTarget.value
    } else {
      return 0
    }
  }

  calculateTotal() {
    let subtotal
    if (document.getElementById('total') != null) {
      subtotal = Array.from(document.querySelectorAll('.subtotal'))
        .reduce((total, arg) => total + parseFloat(arg.innerHTML), 0.0).toFixed(2).toString();
    }

    document.getElementById('total').innerHTML = '$' + subtotal

    return parseFloat(subtotal)
  }

  toggle() {
    this.checkBoxTarget.checked ? this.subtotalTarget.setAttribute('class', 'subtotal') : this.subtotalTarget.removeAttribute('class')
    this.calculateAll()
  }

  calculateBalance() {
    const balance = this.getBalance()
    if (isNaN(balance)) return;

    const balanceElement = document.getElementById("balance")

    let USDollar = new Intl.NumberFormat('en-US', {
      style: 'currency',
      currency: 'USD',
    });

    if (balanceElement) {
      balanceElement.innerHTML = USDollar.format(balance)
      balanceElement.parentElement.className = `balance ${this.getBalanceColorClass(
        balance
      )}`
    }
  }

  calculateAmountTotal(): number {
    const invoicePaymentElements = Array.from(
      document.querySelectorAll(".invoice-payment")
    )
    const invoicePaymentTotal = invoicePaymentElements
      .reduce((total, element) => {
        const elementValue = parseFloat(element.innerHTML.replace(/[$-]/g, ""))
        return total + (isNaN(elementValue) ? 0 : elementValue)
      }, 0.0)
      .toFixed(2)
    return parseFloat(invoicePaymentTotal)
  }

  getBalance(): number {
    return this.calculateTotal() - this.calculateAmountTotal()
  }

  getBalanceColorClass(balance: number): string {
    if (balance < 0) {
      return "negative_balance"
    } else if (balance > 0) {
      return "positive_balance"
    } else {
      return "default_balance"
    }
  }

  updateDays(num_of_days) {
    this.daysTargets.forEach(target => target.innerHTML = num_of_days.toString())
  }
}
