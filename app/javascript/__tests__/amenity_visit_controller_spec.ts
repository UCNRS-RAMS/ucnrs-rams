import { Application, Controller } from "@hotwired/stimulus"
import { renderDOM, clearDOM } from "./support/dom"
import AmenityVisitController from "../controllers/amenity_visit_controller"


describe("AmenityVisitController", () => {
  beforeAll(() => {
    const application = Application.start()
    application.register("amenity-visit", AmenityVisitController)
  })

  afterEach(() => clearDOM())

  beforeEach(() => {
    renderDOM(`
    <span data-controller="followup-content">
    <section class="reserve-info progress-steps">
      <div><h3>Reserves <a href="#">Browse Our Reserves</a></h3></div>
      <div class="display-row-flex">
        <div class="field">
         <label for="visit_reserve_id">Which reserve would you like to visit?</label>
          <turbo-frame id="reserves_select" data-pattern="/visits/reserves?project_type=VALUE" data-turbo-content-target="destination" src="http://localhost:3000/visits/reserves?project_type=meeting_or_conference">
            <select id="visit_reserve_id" name="visit[reserve_id]" data-action="change->followup-content#change" class="reserve-field">
                <option value="-1"></option>
                <option value="4">Big Sur Conference Center</option>
                <option value="7">Oak Ridge</option>
                <option value="6">Single Tree, A</option>
                <option value="5">Sunny Los Angeles Marine Center</option>
                <option value="1">UC Reserve</option>
            </select>
          </turbo-frame>
        </div>
        <div class="date-range-select">
          <div class="field">
            <label class="reserve-lable" for="visit_start_date">Arrival</label>
            <div class="date-time-select">
              <input value="2022-09-29" min="2022-09-28" data-action="change->copy-first#copy" type="date" name="visit[start_date]" id="visit_start_date">
              <select name="visit[start_time]" id="visit_start_time"><option value="00:00">12:00 AM</option>
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
          <span class="separator"></span>
          <div class="field">
            <label for="visit_end_date">Departure</label>
            <div class="date-time-select">
              <input value="2022-10-05" min="2022-09-28" data-action="change->copy-second#copy" type="date" name="visit[end_date]" id="visit_end_date">
              <select name="visit[end_time]" id="visit_end_time"><option value="00:00">12:00 AM</option>
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
        </div>
      </div>
      <div data-followup-content-target="destination" data-followup-content-url-value="http://localhost:3000/visits/reserve_inputs/VALUE" class="reserve-specific-fields">  <div class="field">
        <label for="reserve-special-needs">Special Needs</label>
        <p class="special-needs-statement"></p>
        <textarea name="visit[special_needs]" id="reserve-special-needs"></textarea>
      </div>
      <div class="field">
        <label for="visit_study_area">Study Area</label>
        <input name="visit[study_area]" id="visit_study_area" value="">
      </div>
     <div class="alert_message"></div>
     </div>
    </section>
    <section class="amenities visit-form" data-followup-content-target="destination" data-followup-content-url-value="http://localhost:3000/visits/amenities?reserve_id=VALUE"><div class="amenities-header">
      <h2>Select Amenities<span>(Optional)</span></h2>
      <p>Rate determined automatically from your Institution (Totally a Real University)</p>
    </div>
      <div class="amenity_group" data-controller="amenity-category">
        <a data-action="click->amenity-category#toggle" data-remote="true" href="#">
          <h3>
            <img data-amenity-category-target="maxImage" src="/assets/maximize-820adfa37096fff6a23e557ae6dc9f01b02eb3ff107f2948d1536f602c8d4161.svg" width="30" height="24" style="display: none;">
            <img data-amenity-category-target="minImage" src="/assets/minimize-7fcc982e2f50da385afb8c3c379c10b58c39830ee0bd585c73fa70853cda3d4b.svg" width="30" height="24" style="display: block;">
            <span class="group_label">Housing</span>
          </h3>
        </a>
        <div data-amenity-category-target="amenitiesDiv" style="display: block;">
        <div class="amenity" data-controller="amenity-booking">
      <input type="radio" name="visit[amenities][1][amenity_id]" id="amenity-1" value="1" data-amenity-booking-target="amenityRadioBtn" data-amenity-category-target="amenityRadioBtn">
      <label for="amenity-1">
        <div class="amenity-padding">
          <img alt="picture of a reserve amenity" src="/assets/amenity_placeholder-f055fbe2d8921cbe68868287eadf190be62ca901b22b817693c893680640f1f6.jpg">
          <div class="content" data-controller="toggle">
            <h3>UC Public Housing Amenity</h3>
            <p class="description"></p>
            <div class="comment-and-rates" data-toggle-target="toggle" data-toggle-class="showing">
              <p></p>
                <p>$45.00 per person/per day</p>
                <p>$1.00 per person/per day</p>
                <p>$3.00 per person/per day</p>
            </div>
            <a data-action="click->toggle#toggle" data-toggle-class="showing" data-toggle-target="toggle" class="showing" href="#">Learn More</a>
            <a data-action="click->toggle#toggle" data-toggle-class="showing" data-toggle-target="toggle" href="#">Show Less</a>
          </div>
            <div class="rates">
      <p class="bold">$45.00 per person/per day</p>
      <input value="1" autocomplete="off" type="hidden" name="visit[amenities][1][amenity_rate_id]" id="visit_amenities_1_amenity_rate_id">
      </div>

        </div>
        <div class="bookings">
          <div class="booking">
            <turbo-frame id="amenity_1">

      <div class="booking-card" data-amenity-booking-target="bookingCard" data-controller="subtotal amenity-visit">
          <input data-amenity-visit-target="id" autocomplete="off" type="hidden" name="visit[amenities][1][amenity_visits][a21ab4acc255da7fea65f5e001fda437][id]" id="visit_amenities_1_amenity_visits_a21ab4acc255da7fea65f5e001fda437_id">
        <div class="flex-row-field">
          <div class="flex-column-field">
            <label class="label-error" for="visit_amenities_1_amenity_visits_a21ab4acc255da7fea65f5e001fda437_arrives_on">Arrives on</label>
            <input value="" data-copy-first-target="destination" data-amenity-booking-target="arriveOn" data-amenity-visit-target="arriveOn" data-subtotal-target="arriveOn" data-action="change->subtotal#calculateSubtotal" id="visit_amenities_1_arrives_on" type="date" name="visit[amenities][1][amenity_visits][a21ab4acc255da7fea65f5e001fda437][arrives_on]">
          </div>
          <div class="flex-column-field">
            <label class="label-error" for="visit_amenities_1_amenity_visits_a21ab4acc255da7fea65f5e001fda437_departs_on">Departs on</label>
            <input value="" data-copy-second-target="destination" data-amenity-booking-target="departsOn" data-amenity-visit-target="departsOn" data-subtotal-target="departsOn" data-action="change->subtotal#calculateSubtotal" id="visit_amenities_1_departs_on" type="date" name="visit[amenities][1][amenity_visits][a21ab4acc255da7fea65f5e001fda437][departs_on]">
          </div>
        </div>
        <div class="flex-column-field">
          <label for="visit_amenities_1_amenity_visits_a21ab4acc255da7fea65f5e001fda437_arrive_at">Time of use</label>
          <div class="flex-row-field">
            <select data-amenity-booking-target="arriveAt" data-subtotal-target="arriveAt" data-action="change->subtotal#calculateSubtotal" id="visit_amenities_1_arrives_at" name="visit[amenities][1][amenity_visits][a21ab4acc255da7fea65f5e001fda437][arrives_at]"><option value="00:00">12:00 AM</option>
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
                    <select data-amenity-booking-target="departsAt" data-subtotal-target="departsAt" data-action="change->subtotal#calculateSubtotal" id="visit_amenities_1_departs_at" name="visit[amenities][1][amenity_visits][a21ab4acc255da7fea65f5e001fda437][departs_at]"><option value="00:00">12:00 AM</option>
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
        <div data-controller="counter">
          <div class="flex-row-field">
            <div class="flex-column-filed">
              <label for="visit_amenities_1_amenity_visits_a21ab4acc255da7fea65f5e001fda437_number_of_people">Count</label>
              <div class="flex-row-field">
                <button name="button" type="button" class="less">
                  <img data-action="click->counter#decrement click->subtotal#calculateSubtotal" src="/assets/icon-minus-17425e804ec745badb1514351fdb3cd954d1ef7e5afa9859edc401f9356fea14.svg">
                </button>
                <input value="1" data-counter-target="output" data-subtotal-target="count" data-amenity-booking-target="count" data-action="input->subtotal#calculateSubtotal" class="counter" id="visit_amenities_1_number_of_people" type="text" name="visit[amenities][1][amenity_visits][a21ab4acc255da7fea65f5e001fda437][number_of_people]">
                <button name="button" type="button" class="more">
                  <img data-action="click->counter#increment click->subtotal#calculateSubtotal" src="/assets/icon-plus-d5bab8cd2b36a96d1a7767b0879164c016ac71ea8151d22362734be264880ced.svg">
                </button>
              </div>
            </div>
            <div class="field">
              <label>Subtotal</label>
              <p data-subtotal-target="initialVal" ,="" data-amenity-booking-target="initialVal" hidden=""> 45.00</p>
              <p data-subtotal-target="unitType" hidden=""> day</p>
              <span class="subtotal"  id="subtotal" data-subtotal-target="subtotal" ,="" data-amenity-booking-target="subtotal">135.00</span>
            </div>
            <div class="cross-icon">
              <button name="button" type="button">
                <img data-action="click->amenity-booking#removeAmenityBooking" src="/assets/cross-eef7c4580e8b57b4956828b9391c78c72728ce1916f13ebbea6c2a5fdbdc7547.svg">
              </button>
            </div>
          </div>
        </div>
      </div>

      <div class="bookings">
      <div class="booking">
        <turbo-frame id="amenity_1">

      <div class="booking-card" data-amenity-booking-target="bookingCard" data-controller="subtotal amenity-visit">
      <input data-amenity-visit-target="id" autocomplete="off" type="hidden" name="visit[amenities][1][amenity_visits][a21ab4acc255da7fea65f5e001fda437][id]" id="visit_amenities_1_amenity_visits_a21ab4acc255da7fea65f5e001fda437_id">
      <div class="flex-row-field">
      <div class="flex-column-field">
        <label class="label-error" for="visit_amenities_1_amenity_visits_a21ab4acc255da7fea65f5e001fda437_arrives_on">Arrives on</label>
        <input value="2022-09-30" data-copy-first-target="destination" data-amenity-booking-target="arriveOn" data-amenity-visit-target="arriveOn" data-subtotal-target="arriveOn" data-action="change->subtotal#calculateSubtotal" id="visit_amenities_1_arrives_on" type="date" name="visit[amenities][1][amenity_visits][a21ab4acc255da7fea65f5e001fda437][arrives_on]">
      </div>
      <div class="flex-column-field">
        <label class="label-error" for="visit_amenities_1_amenity_visits_a21ab4acc255da7fea65f5e001fda437_departs_on">Departs on</label>
        <input value="2022-10-1" data-copy-second-target="destination" data-amenity-booking-target="departsOn" data-amenity-visit-target="departsOn" data-subtotal-target="departsOn" data-action="change->subtotal#calculateSubtotal" id="visit_amenities_1_departs_on" type="date" name="visit[amenities][1][amenity_visits][a21ab4acc255da7fea65f5e001fda437][departs_on]">
      </div>
      </div>
      <div class="flex-column-field">
      <label for="visit_amenities_1_amenity_visits_a21ab4acc255da7fea65f5e001fda437_arrive_at">Time of use</label>
      <div class="flex-row-field">
        <select data-amenity-booking-target="arriveAt" data-subtotal-target="arriveAt" data-action="change->subtotal#calculateSubtotal" id="visit_amenities_1_arrives_at" name="visit[amenities][1][amenity_visits][a21ab4acc255da7fea65f5e001fda437][arrives_at]"><option value="00:00">12:00 AM</option>
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
              <select data-amenity-booking-target="departsAt" data-subtotal-target="departsAt" data-action="change->subtotal#calculateSubtotal" id="visit_amenities_1_departs_at" name="visit[amenities][1][amenity_visits][a21ab4acc255da7fea65f5e001fda437][departs_at]"><option value="00:00">12:00 AM</option>
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
      <div data-controller="counter">
      <div class="flex-row-field">
        <div class="flex-column-filed">
          <label for="visit_amenities_1_amenity_visits_a21ab4acc255da7fea65f5e001fda437_number_of_people">Count</label>
          <div class="flex-row-field">
            <button name="button" type="button" class="less">
              <img data-action="click->counter#decrement click->subtotal#calculateSubtotal" src="/assets/icon-minus-17425e804ec745badb1514351fdb3cd954d1ef7e5afa9859edc401f9356fea14.svg">
            </button>
            <input value="1" data-counter-target="output" data-subtotal-target="count" data-amenity-booking-target="count" data-action="input->subtotal#calculateSubtotal" class="counter" id="visit_amenities_1_number_of_people" type="text" name="visit[amenities][1][amenity_visits][a21ab4acc255da7fea65f5e001fda437][number_of_people]">
            <button name="button" type="button" class="more">
              <img data-action="click->counter#increment click->subtotal#calculateSubtotal" src="/assets/icon-plus-d5bab8cd2b36a96d1a7767b0879164c016ac71ea8151d22362734be264880ced.svg">
            </button>
          </div>
        </div>
        <div class="field">
          <label>Subtotal</label>
          <p data-subtotal-target="initialVal" ,="" data-amenity-booking-target="initialVal" hidden=""> 45.00</p>
          <p data-subtotal-target="unitType" hidden=""> day</p>
          <span class="subtotal"  id="subtotal1" data-subtotal-target="subtotal" ,="" data-amenity-booking-target="subtotal">90.00</span>
        </div>
        <div class="cross-icon">
          <button name="button" type="button">
            <img data-action="click->amenity-booking#removeAmenityBooking" src="/assets/cross-eef7c4580e8b57b4956828b9391c78c72728ce1916f13ebbea6c2a5fdbdc7547.svg">
          </button>
        </div>
      </div>
         </div>
     </div>
    </turbo-frame>
        <a class="add-booking-card" data-method="get" href="/visits/new/amenity_booking?amenity_id=1&amp;amenity_rate_id=1">
          <img src="/assets/icon-plus-d5bab8cd2b36a96d1a7767b0879164c016ac71ea8151d22362734be264880ced.svg">
          <span>Add Another Date Range</span>
        </a></div></div></label></div></div></div></section>
   </span>
   `)
  })

  describe("#connect", () => {
    it("set values of arrivesOn and departsOn when their are empty string and calculate subtotal and vice versa", () => {
      const subtotalForEmptyDate = document.getElementById("subtotal")
      const subtotalForNonEmptyDate = document.getElementById("subtotal1")

      expect(subtotalForEmptyDate.textContent).toEqual('135.00')
      expect(subtotalForNonEmptyDate.textContent).toEqual('90.00')
    })
  })
})
