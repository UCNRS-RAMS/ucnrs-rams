import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["initialVal", "subtotal", "count" , "amenityRadioBtn", "arriveOn", "departsOn", "arriveAt", "departsAt", "bookingCards", "bookingCard"]
  declare countTarget: HTMLInputElement
  declare subtotalTarget: HTMLInputElement
  declare initialValTarget: HTMLInputElement
  declare amenityRadioBtnTarget: HTMLInputElement
  declare arriveOnTarget: HTMLInputElement
  declare departsOnTarget: HTMLInputElement
  declare arriveAtTarget: HTMLInputElement
  declare departsAtTarget: HTMLInputElement
  declare bookingCardsTarget: HTMLInputElement
  declare bookingCardTarget: HTMLInputElement
  declare bookingCardTargets: any


  addAmenityBooking(e){
    this.bookingCardsTarget.insertAdjacentHTML('beforeend',this.bookingCard())
  }

  removeAmenityBooking(e){
    if(this.bookingCardTargets.length > 1) {
      e.currentTarget.closest('.booking-card').remove()
    } else {
      this.resetFields()
    }
  }

  resetFields(){
    this.amenityRadioBtnTarget.checked = false
    this.subtotalTarget.textContent = this.initialValTarget.textContent
    this.countTarget.value = '1'
    this.arriveAtTarget.value = '12:00'
    this.departsAtTarget.value = '12:00'
    this.arriveOnTarget.value = ''
    this.departsOnTarget.value = ''
  }

  bookingCard(){
    const id = this.bookingCardsTarget.children.length + 1
    return `<div class="booking-card" data-amenity-booking-target="bookingCard">
      <div class="flex-column-field">
        <div class="flex-row-field">
          <label for="visit_amenities_6_arrives_on_${id}">Arrives on</label>
          <label for="visit_amenities_6_departs_on_${id}">Departs on</label>
        </div>
        <div class="flex-row-field">
          <input value="2020-09-30" data-copy-first-target="destination" data-amenity-booking-target="arriveOn"
            type="date" name="visit[amenities][6][arrives_on_${id}]" id="visit_amenities_6_arrives_on_${id}">
          <input value="2020-10-07" data-copy-second-target="destination" data-amenity-booking-target="departsOn"
            type="date" name="visit[amenities][6][departs_on_${id}]" id="visit_amenities_6_departs_on_${id}">
        </div>
      </div>
      <div class="flex-column-field">
        <label for="visit_amenities_6_arrives_at_${id}">Time of Use</label>
        <div class="flex-row-field">
          <select data-amenity-booking-target="arriveAt" name="visit[amenities][6][arrives_at_${id}]"
            id="visit_amenities_6_arrives_at">
            <option value="00:00">12:00 AM</option>
            <option value="01:00">1:00 AM</option>
            <option value="02:00">2:00 AM</option>
            <option value="03:00">3:00 AM</option>
            <option value="04:00">4:00 AM</option>
            <option value="05:00">5:00 AM</option>
            <option value="06:00">6:00 AM</option>
            <option value="07:00">7:00 AM</option>
            <option value="08:00">8:00 AM</option>
            <option value="09:00">9:00 AM</option>
            <option value="10:00">10:00 AM</option>
            <option value="11:00">11:00 AM</option>
            <option selected="selected" value="12:00">12:00 PM</option>
            <option value="13:00">1:00 PM</option>
            <option value="14:00">2:00 PM</option>
            <option value="15:00">3:00 PM</option>
            <option value="16:00">4:00 PM</option>
            <option value="17:00">5:00 PM</option>
            <option value="18:00">6:00 PM</option>
            <option value="19:00">7:00 PM</option>
            <option value="20:00">8:00 PM</option>
            <option value="21:00">9:00 PM</option>
            <option value="22:00">10:00 PM</option>
            <option value="23:00">11:00 PM</option>
          </select>
          <select data-amenity-booking-target="departsAt" name="visit[amenities][6][departs_at_${id}]"
            id="visit_amenities_6_departs_at">
            <option value="00:00">12:00 AM</option>
            <option value="01:00">1:00 AM</option>
            <option value="02:00">2:00 AM</option>
            <option value="03:00">3:00 AM</option>
            <option value="04:00">4:00 AM</option>
            <option value="05:00">5:00 AM</option>
            <option value="06:00">6:00 AM</option>
            <option value="07:00">7:00 AM</option>
            <option value="08:00">8:00 AM</option>
            <option value="09:00">9:00 AM</option>
            <option value="10:00">10:00 AM</option>
            <option value="11:00">11:00 AM</option>
            <option selected="selected" value="12:00">12:00 PM</option>
            <option value="13:00">1:00 PM</option>
            <option value="14:00">2:00 PM</option>
            <option value="15:00">3:00 PM</option>
            <option value="16:00">4:00 PM</option>
            <option value="17:00">5:00 PM</option>
            <option value="18:00">6:00 PM</option>
            <option value="19:00">7:00 PM</option>
            <option value="20:00">8:00 PM</option>
            <option value="21:00">9:00 PM</option>
            <option value="22:00">10:00 PM</option>
            <option value="23:00">11:00 PM</option>
          </select>
        </div>
      </div>
      <div data-controller="counter subtotal">
        <div class="flex-row-field">
          <div class="flex-column-filed">
            <label for="visit_amenities_6_number_of_people_${id}">Count</label>
            <div class="flex-row-field">
              <button name="button" type="button">
                <img data-action="click->counter#decrement click->subtotal#calculateSubtotal"
                  src="/assets/icon-minus-17425e804ec745badb1514351fdb3cd954d1ef7e5afa9859edc401f9356fea14.svg">
              </button> <input value="1" data-counter-target="output" data-subtotal-target="count"
                data-amenity-booking-target="count" data-action="input->subtotal#calculateSubtotal" class="counter"
                type="text" name="visit[amenities][6][number_of_people_${id}]" id="visit_amenities_6_number_of_people_${id}">
              <button name="button" type="button">
                <img data-action="click->counter#increment click->subtotal#calculateSubtotal"
                  src="/assets/icon-plus-d5bab8cd2b36a96d1a7767b0879164c016ac71ea8151d22362734be264880ced.svg">
              </button> </div>
          </div>
          <div class="field">
            <label>Subtotal</label>
            <p data-subtotal-target="initialVal" data-amenity-booking-target="initialVal" hidden="">${this.initialValTarget.innerText}</p>
            <span data-subtotal-target="subtotal" data-amenity-booking-target="subtotal">${this.initialValTarget.innerText}</span>
          </div>
          <div class="cross-icon">
            <button name="button" type="button" id="close-btn-${id}">
              <img data-action="click->amenity-booking#removeAmenityBooking"
                src="/assets/cross.svg">
            </button>
          </div>
        </div>
      </div>
    </div>`
  }
}
