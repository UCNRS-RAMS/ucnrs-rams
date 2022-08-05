import { Application, Controller } from "@hotwired/stimulus"
import { renderDOM, clearDOM } from "./support/dom"
import SubtotalController from "../controllers/subtotal_controller"
import CounterController from "../controllers/counter_controller"

global.fetch = jest.fn(() =>
  Promise.resolve({
    ok: true,
    json: () => Promise.resolve({data: 5}),
  })
)

const allowFetchToResolveAfter = (timeout = 1) =>
  new Promise((r) => setTimeout(r, timeout))

describe("SubtotalController", () => {
  beforeAll(() => {
    const application = Application.start()
    application.register("counter", CounterController)
    application.register("subtotal", SubtotalController)
  })

  afterEach(() => clearDOM())

  beforeEach(() => {
    renderDOM(`
      <section data-controller="subtotal counter">
      <input id="count" data-subtotal-target="count" data-counter-target="output" value="NaN"/>
      <span id="subtotal" data-subtotal-target="subtotal"></span>
      <p id="initialVal" data-subtotal-target="initialVal" hidden></p>
      <p id="unit" data-subtotal-target="unitType"></p>
      <input type="date" id="arrive-on" data-subtotal-target="arriveOn"/>
      <input type="date" id="departs-on" data-subtotal-target="departsOn"/>
      <select type="select" id="departs-at" data-subtotal-target="departsAt">
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
      <select type="select" id="arrive-at" data-subtotal-target="arriveAt">
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
       <input type="button" id="down" data-action="click->counter#decrement click->subtotal#calculateSubtotal"/>
        <input type="button" id="up" data-action="click->counter#increment click->subtotal#calculateSubtotal"/>
      <input type="button" id="close-btn" data-action="click->amenity-booking#removeAmenityBooking">
      </section>`)
  })

  describe("#calculateSubtotal", () => {
    it("calculates the subtotal based on the count of people", async () => {
      const count = document.getElementById("count")
      const subtotal = document.getElementById("subtotal")
      const initialVal = document.getElementById("initialVal")
      const arrivesOn = document.getElementById("arrive-on")
      const departsOn = document.getElementById("departs-on")
      const unit = document.getElementById("unit")

      count.value = "1"
      initialVal.textContent = "5"
      arrivesOn.value = '2022-12-12'
      departsOn.value = '2022-12-13'
      unit.innerText = "night"

      const up = document.getElementById("up")

      up.click()
      await allowFetchToResolveAfter()

      expect(fetch).toHaveBeenCalledWith( `/visits/units?arrive=${encodeURIComponent('2022-12-12 12:00')}&departs=${encodeURIComponent('2022-12-13 12:00')}&unit=night`, {"headers": {"Content-Type": "application/json"}})
      expect(subtotal.innerText).toEqual("50.00")
    })
  })
})
