import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["initialVal", "subtotal", "rate", "count" , "amenityRadioBtn", "arriveOn", "departsOn", "arriveAt", "departsAt", "bookingCards", "bookingCard"]
  declare countTarget: HTMLInputElement
  declare subtotalTarget: HTMLInputElement
  declare rateTarget: HTMLSelectElement
  declare initialValTarget: HTMLInputElement
  declare amenityRadioBtnTarget: HTMLInputElement
  declare arriveOnTarget: HTMLInputElement
  declare departsOnTarget: HTMLInputElement
  declare arriveAtTarget: HTMLInputElement
  declare departsAtTarget: HTMLInputElement
  declare bookingCardsTarget: HTMLInputElement
  declare bookingCardTarget: HTMLInputElement
  declare bookingCardTargets: any

  removeAmenityBooking(e){
    if(this.bookingCardTargets.length > 1) {
      e.currentTarget.closest('.booking-card').remove()
    } else {
      this.resetFields()
    }
  }

  calculateSubtotal() {
    const rate = this.rateTarget.options[this.rateTarget.selectedIndex].innerText.match(/\d+/)[0]
    this.bookingCardTargets.forEach(target => this.application.getControllerForElementAndIdentifier(target, "subtotal").setRate(rate))
  }

  resetFields(){
    this.amenityRadioBtnTarget.checked = false
    this.countTarget.value = '1'
    this.arriveAtTarget.value = '12:00'
    this.departsAtTarget.value = '12:00'
  }
}
