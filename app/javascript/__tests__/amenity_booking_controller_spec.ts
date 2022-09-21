import { Application, Controller } from "@hotwired/stimulus"
import { renderDOM, clearDOM } from "./support/dom"
import AmenityBookingController from "../controllers/amenity_booking_controller"


describe("AmenityBookingController", () => {
  beforeAll(() => {
    const application = Application.start()
    application.register("amenity-booking", AmenityBookingController)
  })

  afterEach(() => clearDOM())

  beforeEach(() => {
    renderDOM(`
      <section id="bookingCards" data-controller="amenity-booking" data-amenity-booking-Target = "bookingCards">
        <section id="bookingCard" class="booking-card" data-amenity-booking-Target = "bookingCard">
          <input id="count-1" data-amenity-booking-target="count" value="NaN"/>
          <span id="subtotal-1" data-amenity-booking-target="subtotal"></span>
          <p id="initialVal-1" data-amenity-booking-target="initialVal" hidden></p>
          <input type="radio" id="radio" data-amenity-booking-target="amenityRadioBtn"/>
          <input type="date" id="arrive-on-1" data-amenity-booking-target="arriveOn"/>
          <input type="date" id="departs-on-1" data-amenity-booking-target="departsOn"/>
          <select type="select" id="departs-at-1" data-amenity-booking-target="departsAt">
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
          <select type="select" id="arrive-at-1" data-amenity-booking-target="arriveAt">
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
          <input type="button" id="close-btn-1" data-action="click->amenity-booking#removeAmenityBooking">
        </section>
        <section id="bookingCard" class="booking-card" data-amenity-booking-Target = "bookingCard">
          <input id="count-2" data-amenity-booking-target="count" value="NaN"/>
          <span id="subtotal-2" data-amenity-booking-target="subtotal"></span>
          <p id="initialVal-2" data-amenity-booking-target="initialVal" hidden></p>
          <input type="radio" id="radio" data-amenity-booking-target="amenityRadioBtn"/>
          <input type="date" id="arrive-on-2" data-amenity-booking-target="arriveOn"/>
          <input type="date" id="departs-on-2" data-amenity-booking-target="departsOn"/>
          <select type="select" id="departs-at-2" data-amenity-booking-target="departsAt">
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
          <select type="select" id="arrive-at-2" data-amenity-booking-target="arriveAt">
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
          <input type="button" id="close-btn-2" data-action="click->amenity-booking#removeAmenityBooking">
        </section>
      </section>`)
  })

  describe("#removeAmenityBooking", () => {
    it("checks if the amenity booking is removed", () => {
      const bookingCards = document.getElementById("bookingCards")

      expect(bookingCards.childElementCount).toEqual(2)

      document.getElementById("close-btn-2").click()

      expect(bookingCards.childElementCount).toEqual(1)
    })

    it("reset the values when click on cross-icon-btn", () => {
      const count = document.getElementById("count-1")
      const subtotal = document.getElementById("subtotal-1")
      const initailVal = document.getElementById("initialVal-1")
      const arriveOn = document.getElementById("arrive-on-1")
      const departsOn = document.getElementById("departs-on-1")
      const departsAt = document.getElementById("departs-at-1")
      const arriveAt = document.getElementById("arrive-at-1")

      count.value = "2"
      subtotal.textContent = "4"
      initailVal.textContent = "2"
      arriveAt.value = "08:00"
      departsAt.value = "10:00"
      departsOn.value = "1999-10-05"
      arriveOn.value = "1999-10-02"

      document.getElementById("close-btn-2").click()
      document.getElementById("close-btn-1").click()

      expect(subtotal.textContent).toEqual("2")
      expect(count.value).toEqual("1")
      expect(arriveAt.value).toEqual("12:00")
      expect(arriveAt.value).toEqual("12:00")
    })
  })
})
