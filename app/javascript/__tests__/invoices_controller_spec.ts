import { Application } from "@hotwired/stimulus"
import { renderDOM, clearDOM } from "./support/dom"
import InvoicesController from "../controllers/invoices_controller"

describe("InvoicesController", () => {
  beforeAll(() => {
    const application = Application.start()
    application.register("invoices", InvoicesController)
  })

  afterEach(() => clearDOM())

  describe("#days", () => {
    it("calculates the number of days between dates", (done) => {
      renderDOM(`
        <div data-controller="invoices">
          <input data-invoices-target="arriveOn"
            value="2026-03-01"/>
          <input data-invoices-target="departsOn"
            value="2026-03-05"/>
          <span id="days" data-invoices-target="days"></span>
          <input type="checkbox" data-invoices-target="checkBox"
            checked/>
          <span data-invoices-target="subtotal"
            class="subtotal"></span>
        </div>`)

      setTimeout(() => {
        const days = document.getElementById("days")
        expect(days.innerHTML).toEqual("5")
        done()
      })
    })

    it("defaults to 1 when dates are invalid", (done) => {
      renderDOM(`
        <div data-controller="invoices">
          <input data-invoices-target="arriveOn" value=""/>
          <input data-invoices-target="departsOn" value=""/>
          <span id="days" data-invoices-target="days"></span>
          <input type="checkbox" data-invoices-target="checkBox"
            checked/>
          <span data-invoices-target="subtotal"
            class="subtotal"></span>
        </div>`)

      setTimeout(() => {
        const days = document.getElementById("days")
        expect(days.innerHTML).toEqual("1")
        done()
      })
    })

    it("returns at least 1 day for same-day dates", (done) => {
      renderDOM(`
        <div data-controller="invoices">
          <input data-invoices-target="arriveOn"
            value="2026-03-10"/>
          <input data-invoices-target="departsOn"
            value="2026-03-10"/>
          <span id="days" data-invoices-target="days"></span>
          <input type="checkbox" data-invoices-target="checkBox"
            checked/>
          <span data-invoices-target="subtotal"
            class="subtotal"></span>
        </div>`)

      setTimeout(() => {
        const days = document.getElementById("days")
        expect(days.innerHTML).toEqual("1")
        done()
      })
    })
  })

  describe("#check", () => {
    it("removes class from subtotal when unchecked", (done) => {
      renderDOM(`
        <div data-controller="invoices">
          <input data-invoices-target="arriveOn"
            value="2026-03-01"/>
          <input data-invoices-target="departsOn"
            value="2026-03-05"/>
          <span data-invoices-target="days"></span>
          <input type="checkbox"
            data-invoices-target="checkBox"/>
          <span id="subtotal" data-invoices-target="subtotal"
            class="subtotal"></span>
        </div>`)

      setTimeout(() => {
        const subtotal = document.getElementById("subtotal")
        expect(subtotal.getAttribute("class")).toBeFalsy()
        done()
      })
    })

    it("keeps class on subtotal when checked", (done) => {
      renderDOM(`
        <div data-controller="invoices">
          <input data-invoices-target="arriveOn"
            value="2026-03-01"/>
          <input data-invoices-target="departsOn"
            value="2026-03-05"/>
          <span data-invoices-target="days"></span>
          <input type="checkbox" data-invoices-target="checkBox"
            checked/>
          <span id="subtotal" data-invoices-target="subtotal"
            class="subtotal"></span>
        </div>`)

      setTimeout(() => {
        const subtotal = document.getElementById("subtotal")
        expect(subtotal.getAttribute("class"))
          .toEqual("subtotal")
        done()
      })
    })
  })
})
