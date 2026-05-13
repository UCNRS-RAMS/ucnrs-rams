import { Application } from "@hotwired/stimulus"
import controller from "../controllers/summary_box_controller"
import { renderDOM, clearDOM } from "./support/dom"

const application = Application.start()
application.register("summary-box", controller)

const html = `
  <div data-controller="summary-box">
    <button id="staff-btn"
      data-action="click->summary-box#alertMessage"
      data-summary-box-staff-member-param="true"
      data-summary-box-visit-id-param="42">
      Delete (staff)
    </button>
    <button id="non-staff-btn"
      data-action="click->summary-box#alertMessage"
      data-summary-box-staff-member-param="false"
      data-summary-box-visit-id-param="99">
      Delete (non-staff)
    </button>
  </div>
`

afterEach(() => clearDOM())

describe("summary_box controller", () => {
  it("confirms and allows deletion for staff member",
    (done) => {
      renderDOM(html)
      setTimeout(() => {
        window.confirm = jest.fn(() => true)
        const btn = document.getElementById(
          "staff-btn"
        ) as HTMLElement
        const spy = jest.fn()
        btn.addEventListener("click", spy)

        btn.click()

        expect(window.confirm).toHaveBeenCalledWith(
          "You are about to delete visit # 42" +
          " and all Invoices attached to this visit."
        )
        expect(spy).toHaveBeenCalled()
        done()
      })
    }
  )

  it("confirms and prevents deletion when staff cancels",
    (done) => {
      renderDOM(html)
      setTimeout(() => {
        window.confirm = jest.fn(() => false)
        const btn = document.getElementById(
          "staff-btn"
        ) as HTMLElement

        const preventSpy = jest.fn()
        btn.addEventListener("click", preventSpy)

        btn.click()

        expect(window.confirm).toHaveBeenCalled()
        expect(preventSpy).not.toHaveBeenCalled()
        done()
      })
    }
  )

  it("alerts and prevents deletion for non-staff",
    (done) => {
      renderDOM(html)
      setTimeout(() => {
        window.alert = jest.fn()
        const btn = document.getElementById(
          "non-staff-btn"
        ) as HTMLElement

        const preventSpy = jest.fn()
        btn.addEventListener("click", preventSpy)

        btn.click()

        expect(window.alert).toHaveBeenCalledWith(
          "You are not allowed to delete visits" +
          " from reserves you do not administrate."
        )
        expect(preventSpy).not.toHaveBeenCalled()
        done()
      })
    }
  )
})
