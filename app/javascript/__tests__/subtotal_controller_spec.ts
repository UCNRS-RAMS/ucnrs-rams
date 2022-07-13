import { Application, Controller } from "@hotwired/stimulus"
import { renderDOM, clearDOM } from "./support/dom"
import SubtotalController from "../controllers/subtotal_controller"
import CounterController from "../controllers/counter_controller"


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
        <input type="button" id="down" data-action="click->counter#decrement click->subtotal#calculateSubtotal"/>
        <input type="button" id="up" data-action="click->counter#increment click->subtotal#calculateSubtotal"/>
      </section>`)
  })

  describe("#calculateSubtotal", () => {
    it("calculates the subtotal based on the count of people", () => {
      const count = document.getElementById("count")
      const subtotal = document.getElementById("subtotal")
      const initailVal = document.getElementById("initialVal")

      count.value = "2"
      subtotal.textContent = "10"
      initailVal.textContent = "5"

      const down = document.getElementById("down")
      const up = document.getElementById("up")

      up.click()

      expect(subtotal.innerText).toEqual("15.00")
      down.click()
      down.click()

      expect(subtotal.innerText).toEqual("5.00")
    })
  })
})
