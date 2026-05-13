import { Application, Context } from "@hotwired/stimulus"
import { renderDOM, clearDOM } from "./support/dom"
import SubtotalInvoiceController
  from "../controllers/subtotal_invoice_controller"

global.fetch = jest.fn(() =>
  Promise.resolve({
    ok: true,
    json: () => Promise.resolve({ data: 5 }),
  })
) as jest.Mock

const allowFetchToResolve = (timeout = 1) =>
  new Promise((r) => setTimeout(r, timeout))

function buildDOM(
  { rate = "10.00", checked = true, count = "1" } = {}
) {
  const checkedAttr = checked ? "checked" : ""
  renderDOM(`
    <section data-controller="subtotal-invoice">
      <input id="count" value="${count}"
        data-subtotal-invoice-target="count"/>
      <span id="subtotal" class="subtotal"
        data-subtotal-invoice-target="subtotal"></span>
      <input id="rate" value="${rate}"
        data-subtotal-invoice-target="initialVal"/>
      <p id="unit"
        data-subtotal-invoice-target="unitType">night</p>
      <input type="date" id="arriveOn" value="2026-03-01"
        data-subtotal-invoice-target="arriveOn"/>
      <input type="date" id="departsOn" value="2026-03-05"
        data-subtotal-invoice-target="departsOn"/>
      <input type="time" id="arriveAt" value="12:00"
        data-subtotal-invoice-target="arriveAt"/>
      <input type="time" id="departsAt" value="12:00"
        data-subtotal-invoice-target="departsAt"/>
      <input type="checkbox" id="checkbox" ${checkedAttr}
        data-subtotal-invoice-target="checkBox"
        data-action="change->subtotal-invoice#toggle"/>
      <span id="days"
        data-subtotal-invoice-target="days"></span>
      <strong id="total">$0.00</strong>
      <span id="balance-wrapper" class="balance default_balance">
        <span id="balance">$0.00</span>
      </span>
    </section>`)
}

describe("SubtotalInvoiceController", () => {
  beforeAll(() => {
    const application = Application.start()
    application.register(
      "subtotal-invoice", SubtotalInvoiceController
    )
  })

  afterEach(() => clearDOM())

  describe("#calculateAll", () => {
    it("calculates subtotal from count, rate, and units",
      async () => {
        buildDOM({ rate: "10.00", count: "2" })
        await allowFetchToResolve()

        const subtotal = document.getElementById("subtotal")
        // fetch returns 5 units, rate=10, count=2 => 100.00
        expect(subtotal.innerText).toEqual("100.00")
      }
    )

    it("defaults count to 1 when empty", async () => {
      buildDOM({ rate: "10.00", count: "" })
      await allowFetchToResolve()

      const count = document.getElementById("count") as HTMLInputElement
      expect(count.value).toEqual("1")
    })

    it("defaults count to 1 when less than 1", async () => {
      buildDOM({ rate: "10.00", count: "0" })
      await allowFetchToResolve()

      const count = document.getElementById("count") as HTMLInputElement
      expect(count.value).toEqual("1")
    })
  })

  describe("#rate", () => {
    it("returns rate value when checkbox is checked",
      async () => {
        buildDOM({ rate: "15.00", checked: true })
        await allowFetchToResolve()

        const subtotal = document.getElementById("subtotal")
        // 1 * 15.00 * 5 = 75.00
        expect(subtotal.innerText).toEqual("75.00")
      }
    )

    it("returns 0 when checkbox is unchecked", async () => {
      buildDOM({ rate: "15.00", checked: false })
      await allowFetchToResolve()

      const subtotal = document.getElementById("subtotal")
      expect(subtotal.innerText).toEqual("0.00")
    })
  })

  describe("#toggle", () => {
    it("adds subtotal class when checked", async () => {
      buildDOM({ checked: false })
      await allowFetchToResolve()

      const checkbox = document.getElementById(
        "checkbox"
      ) as HTMLInputElement
      const subtotal = document.getElementById("subtotal")

      checkbox.checked = true
      checkbox.dispatchEvent(
        new Event("change", { bubbles: true })
      )
      await allowFetchToResolve()

      expect(subtotal.getAttribute("class"))
        .toEqual("subtotal")
    })

    it("removes subtotal class when unchecked", async () => {
      buildDOM({ checked: true })
      await allowFetchToResolve()

      const checkbox = document.getElementById(
        "checkbox"
      ) as HTMLInputElement
      const subtotal = document.getElementById("subtotal")

      checkbox.checked = false
      checkbox.dispatchEvent(
        new Event("change", { bubbles: true })
      )
      await allowFetchToResolve()

      expect(subtotal.getAttribute("class")).toBeFalsy()
    })
  })

  describe("#updateDays", () => {
    it("updates days targets with unit count", async () => {
      buildDOM()
      await allowFetchToResolve()

      const days = document.getElementById("days")
      expect(days.innerHTML).toEqual("5")
    })
  })

  describe("#fetchSubtotal", () => {
    it("calls fetch with the correct URL", async () => {
      (fetch as jest.Mock).mockClear()
      buildDOM()
      await allowFetchToResolve()

      expect(fetch).toHaveBeenCalledWith(
        `/visits/units?arrive=${
          encodeURIComponent("2026-03-01 12:00")
        }&departs=${
          encodeURIComponent("2026-03-05 12:00")
        }&unit=night`,
        { headers: { "Content-Type": "application/json" } }
      )
    })
  })

  describe("#getBalanceColorClass", () => {
    it("returns positive_balance for positive values", () => {
      const controller = new SubtotalInvoiceController(
        {} as Context
      )
      expect(controller.getBalanceColorClass(100))
        .toEqual("positive_balance")
    })

    it("returns negative_balance for negative values", () => {
      const controller = new SubtotalInvoiceController(
        {} as Context
      )
      expect(controller.getBalanceColorClass(-50))
        .toEqual("negative_balance")
    })

    it("returns default_balance for zero", () => {
      const controller = new SubtotalInvoiceController(
        {} as Context
      )
      expect(controller.getBalanceColorClass(0))
        .toEqual("default_balance")
    })
  })
})
