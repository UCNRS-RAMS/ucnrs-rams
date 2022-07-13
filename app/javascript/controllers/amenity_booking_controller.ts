import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["initialVal", "subtotal", "count" , "amenityRadioBtn", "arriveOn", "departsOn", "arriveAt", "departsAt"]
  declare countTarget: HTMLInputElement
  declare subtotalTarget: HTMLInputElement
  declare initialValTarget: HTMLInputElement
  declare amenityRadioBtnTarget: HTMLInputElement
  declare arriveOnTarget: HTMLInputElement
  declare departsOnTarget: HTMLInputElement
  declare arriveAtTarget: HTMLInputElement
  declare departsAtTarget: HTMLInputElement

  removeAmenity(){
    this.amenityRadioBtnTarget.checked = false
    this.subtotalTarget.textContent = this.initialValTarget.textContent
    this.countTarget.value = '1'
    this.arriveAtTarget.value = '12:00'
    this.departsAtTarget.value = '12:00'
    this.arriveOnTarget.value = '2020-09-30'
    this.departsOnTarget.value = '2020-10-07'
  }
}
