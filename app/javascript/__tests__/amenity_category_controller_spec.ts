import { Application, Controller } from "@hotwired/stimulus"
import { renderDOM, clearDOM } from "./support/dom"
import AmenityCategoryController from "../controllers/amenity_category_controller"

describe("AmenityCategoryController", () => {
  beforeAll(() => {
    const application = Application.start()
    application.register("amenity-category", AmenityCategoryController)
  })

  afterEach(() => clearDOM())

  beforeEach(() => {
    renderDOM(`
    <div id="amenity_group" class="amenity_group" data-controller="amenity-category">
    <a id="link" data-action="click->amenity-category#toggle" data-remote="true" href="#">
      <h3>
        <img data-amenity-category-target="maxImage" src="/assets/maximize-19d17260e019511ceb3a4b4fef39cb4cf99facb9431963269ad5771331c7d80d.svg" width="30" height="24" style="display: none;">
        <img data-amenity-category-target="minImage" src="/assets/minimize-16bc5e3fcbf0d32bbd78ad37b2be90b5e033c4c51836cfe7553c368b92897d82.svg" width="30" height="24" style="display: block;">
        <span>Stuff to Get</span>
      </h3>
  </a>  <div id="amenities" data-amenity-category-target="amenitiesDiv" style="display: none;">
        
          <div class="amenity" data-controller="amenity-booking">
    <input type="radio" id="radioBtn" name="visit[amenities][7][amenity_id]" id="amenity-7" value="7" data-amenity-booking-target="amenityRadioBtn" data-amenity-category-target="amenityRadioBtn">
    <label for="amenity-7">
      <div class="amenity-padding">
        <img src="">
        <div class="content" data-controller="toggle">
          <h3>Your Own Leaf</h3>
          <p class="description"></p>
          <div class="comment-and-rates" data-toggle-target="toggle" data-toggle-class="showing">
            <p></p>
              <p>$999.99 per person</p>
              <p>$1.00 per person</p>
          </div>
          <a data-action="click->toggle#toggle" data-toggle-class="showing" data-toggle-target="toggle" class="showing" href="#">Learn More</a>
          <a data-action="click->toggle#toggle" data-toggle-class="showing" data-toggle-target="toggle" href="#">Show Less</a>
        </div>
        <div class="rates">
          <p class="bold">$999.99 per person</p>
          <input value="17" autocomplete="off" type="hidden" name="visit[amenities][7][amenity_rate_id]" id="visit_amenities_7_amenity_rate_id">
        </div>
      </div>
      <div class="bookings">
        <div class="booking">
          <div class="booking-cards" data-amenity-booking-target="bookingCards">
              <div class="booking-card" data-amenity-booking-target="bookingCard">
    <div class="flex-column-field">
      <div class="flex-row-field">
        <label for="visit_amenities_7_arrives_on">Arrives on</label>
        <label for="visit_amenities_7_departs_on">Departs on</label>
      </div>
      <div class="flex-row-field">
        <input name="visit[amenities][7][amenity_visits][0][arrives_on]" value="2022-07-27" data-copy-first-target="destination" data-amenity-booking-target="arriveOn" type="date" id="visit_amenities_7_arrives_on">
        <input name="visit[amenities][7][amenity_visits][0][departs_on]" value="2022-07-27" data-copy-second-target="destination" data-amenity-booking-target="departsOn" type="date" id="visit_amenities_7_departs_on">
      </div>
    </div>
    <div class="flex-column-field">
      <label for="visit_amenities_7_arrives_at">Time of use</label>
      <div class="flex-row-field">
        <select data-amenity-booking-target="arriveAt" name="visit[amenities][7][amenity_visits][0][arrives_at]" id="visit_amenities_7_arrives_at"><option value="00:00">12:00 AM</option>
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
  <option value="23:00">11:00 PM</option></select>
        <select data-amenity-booking-target="departsAt" name="visit[amenities][7][amenity_visits][0][departs_at]" id="visit_amenities_7_departs_at"><option value="00:00">12:00 AM</option>
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
  <option value="14:00">2:00 PM</option>const
  const
  <option value="15:00">3:00 PM</option>
  <option value="16:00">4:00 PM</option>
  <option value="17:00">5:00 PM</option>
  <option value="18:00">6:00 PM</option>
  <option value="19:00">7:00 PM</option>
  <option value="20:00">8:00 PM</option>
  <option value="21:00">9:00 PM</option>
  <option value="22:00">10:00 PM</option>
  <option value="23:00">11:00 PM</option></select>
      </div>
    </div>
    <div data-controller="counter subtotal">
      <div class="flex-row-field">
        <div class="flex-column-filed">
          <label for="visit_amenities_7_number_of_people">Count</label>
          <div class="flex-row-field">
            <button name="button" type="button">
              <img data-action="click->counter#decrement click->subtotal#calculateSubtotal" src="/assets/icon-minus-17425e804ec745badb1514351fdb3cd954d1ef7e5afa9859edc401f9356fea14.svg">
  </button>          <input name="visit[amenities][7][amenity_visits][0][number_of_people]" value="1" data-counter-target="output" data-subtotal-target="count" data-amenity-booking-target="count" data-action="input->subtotal#calculateSubtotal" class="counter" type="text" id="visit_amenities_7_number_of_people">
            <button name="button" type="button">
              <img data-action="click->counter#increment click->subtotal#calculateSubtotal" src="/assets/icon-plus-d5bab8cd2b36a96d1a7767b0879164c016ac71ea8151d22362734be264880ced.svg">
  </button>        </div>
        </div>
        <div class="field">
          <label>Subtotal</label>
          <p data-subtotal-target="initialVal" ,="" data-amenity-booking-target="initialVal" hidden=""> 999.99</p>
          <span data-subtotal-target="subtotal" ,="" data-amenity-booking-target="subtotal">999.99</span>
        </div>
        <div class="cross-icon">
          <button name="button" type="button">
            <img data-action="click->amenity-booking#removeAmenityBooking" src="/assets/cross-eef7c4580e8b57b4956828b9391c78c72728ce1916f13ebbea6c2a5fdbdc7547.svg">
  </button>      </div>
      </div>
    </div>
  </div>
  
          </div>
          <div class="add-booking-card">
            <img data-action="click->amenity-booking#addAmenityBooking" src="/assets/icon-plus-d5bab8cd2b36a96d1a7767b0879164c016ac71ea8151d22362734be264880ced.svg"> <span>Add Another Date Range</span>
          </div>
        </div>
      </div>
    </label>
  </div>
  
    </div>
  </div>`)
  })

  describe("#expand", () => {
    it("add amenity card when click on add-icon-btn", () => {
      var amenities = document.getElementById("amenities")
      var radioBtn = document.getElementById("radioBtn")
      var link = document.getElementById("link")
      
      expect(amenities.style.display).toEqual('none')
      link.click()
      expect(amenities.style.display).toEqual('block')
      link.click()
      expect(amenities.style.display).toEqual('none')
      link.click()
      expect(amenities.style.display).toEqual('block')
      radioBtn.click()
      link.click()
      expect(amenities.style.display).toEqual('block')
    })
  })
})
