import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["initial_val", "subtotal", "no_of_people" , "amenity_radio_btn", "arrive_on", "departs_on", "arrive_at", "departs_at", "parent", "child"]
  declare no_of_peopleTarget: HTMLInputElement
  declare subtotalTarget: HTMLInputElement
  declare initial_valTarget: HTMLInputElement
  declare amenity_radio_btnTarget: HTMLInputElement
  declare arrive_onTarget: HTMLInputElement
  declare departs_onTarget: HTMLInputElement
  declare arrive_atTarget: HTMLInputElement
  declare departs_atTarget: HTMLInputElement
  declare parentTarget: HTMLInputElement
  declare childTarget: HTMLInputElement
  
  calsubtotal(){
    if (parseFloat(this.no_of_peopleTarget.value) < 1 || this.no_of_peopleTarget.value == '')
    {
      this.no_of_peopleTarget.value = '1'
    }
    this.subtotalTarget.textContent = (parseFloat(this.no_of_peopleTarget.value) * parseFloat(this.initial_valTarget.textContent)).toString()
  }
  
  removeAmenity(){
    this.amenity_radio_btnTarget.checked = false
    this.subtotalTarget.textContent = this.initial_valTarget.textContent
    this.no_of_peopleTarget.value = '1'
    this.arrive_onTarget.value = '12:00'
    this.departs_onTarget.value = '12:00'
    this.arrive_atTarget.value = '2020-09-30'
    this.departs_atTarget.value = '2020-10-07'
  }
}
