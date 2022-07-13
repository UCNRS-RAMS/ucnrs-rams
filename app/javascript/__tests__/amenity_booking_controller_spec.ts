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
      <section data-controller="amenity-booking">
        <input id="count" data-amenity-booking-target="count" value="NaN"/>
        <span id="subtotal" data-amenity-booking-target="subtotal"></span>
        <p id="initialVal" data-amenity-booking-target="initialVal" hidden></p>
        <input type="radio" id="radio" data-amenity-booking-target="amenityRadioBtn"/>
        <input type="date" id="arrive-on" data-amenity-booking-target="arriveOn"/>
        <input type="date" id="departs-on" data-amenity-booking-target="departsOn"/>
        <select type="select" id="departs-at" data-amenity-booking-target="departsAt">
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
        <select type="select" id="arrive-at" data-amenity-booking-target="arriveAt">
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
        <input type="button" id="close-btn" data-action="click->amenity-booking#removeAmenity"
      </section>`)
  })

  describe("#calculateSubtotal", () => {
    it("calculates the subtotal based on the count of people", () => {
      const count = document.getElementById("count")
      const subtotal = document.getElementById("subtotal")
      const initailVal = document.getElementById("initialVal")
      const arriveOn = document.getElementById("arrive-on")
      const departsOn = document.getElementById("departs-on")
      const departsAt = document.getElementById("departs-at")
      const arriveAt = document.getElementById("arrive-at")

      count.value = "2"
      subtotal.textContent = "4"
      initailVal.textContent = "2"
      arriveAt.value = "08:00"
      departsAt.value = "10:00"
      departsOn.value = "1999-10-05"
      arriveOn.value = "1999-10-02"

      const crossbtn = document.getElementById("close-btn")
      crossbtn.click()

      expect(subtotal.textContent).toEqual("2")
      expect(count.value).toEqual("1")
      expect(departsOn.value).toEqual("2020-10-07")
      expect(arriveOn.value).toEqual("2020-09-30")
      expect(arriveAt.value).toEqual("12:00")
      expect(arriveAt.value).toEqual("12:00")
    })
  })
})
