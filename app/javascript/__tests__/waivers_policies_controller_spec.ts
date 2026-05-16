import { Application } from "@hotwired/stimulus"
import controller from "../controllers/waivers_policies_controller"
import { renderDOM, clearDOM } from "./support/dom"

const application = Application.start()
application.register("waivers-policies", controller)

const html = `
  <div data-controller="waivers-policies">
    <label class="agree">
      <input type="checkbox"
             id="agree1"
             data-waivers-policies-target="agreement"
             data-action="change->waivers-policies#agreementHandler">
      Agreement 1
    </label>
    <label class="agree">
      <input type="checkbox"
             id="agree2"
             data-waivers-policies-target="agreement"
             data-action="change->waivers-policies#agreementHandler">
      Agreement 2
    </label>
    <label>
      <input type="checkbox"
             id="signature"
             data-waivers-policies-target="signature"
             data-action="change->waivers-policies#signatureHandler">
      Signature
    </label>
  </div>
`

afterEach(() => clearDOM())

describe("waivers_policies controller", () => {
  it("unchecks signature if agreements are not checked",
    (done) => {
      renderDOM(html)
      setTimeout(() => {
        const sig = document.getElementById(
          "signature"
        ) as HTMLInputElement
        sig.checked = true
        sig.dispatchEvent(new Event("change", {
          bubbles: true
        }))

        expect(sig.checked).toBe(false)
        done()
      })
    }
  )

  it("sets error class on unchecked agreements",
    (done) => {
      renderDOM(html)
      setTimeout(() => {
        const sig = document.getElementById(
          "signature"
        ) as HTMLInputElement
        sig.checked = true
        sig.dispatchEvent(new Event("change", {
          bubbles: true
        }))

        const label1 = document.getElementById(
          "agree1"
        ).parentElement
        const label2 = document.getElementById(
          "agree2"
        ).parentElement
        expect(label1.className).toBe("agree-error")
        expect(label2.className).toBe("agree-error")
        done()
      })
    }
  )

  it("allows signature when all agreements checked",
    (done) => {
      renderDOM(html)
      setTimeout(() => {
        const agree1 = document.getElementById(
          "agree1"
        ) as HTMLInputElement
        const agree2 = document.getElementById(
          "agree2"
        ) as HTMLInputElement
        agree1.checked = true
        agree2.checked = true

        const sig = document.getElementById(
          "signature"
        ) as HTMLInputElement
        sig.checked = true
        sig.dispatchEvent(new Event("change", {
          bubbles: true
        }))

        expect(sig.checked).toBe(true)
        done()
      })
    }
  )

  it("sets agree class when agreement is checked",
    (done) => {
      renderDOM(html)
      setTimeout(() => {
        const agree1 = document.getElementById(
          "agree1"
        ) as HTMLInputElement
        agree1.checked = true
        agree1.dispatchEvent(new Event("change", {
          bubbles: true
        }))

        expect(agree1.parentElement.className)
          .toBe("agree")
        done()
      })
    }
  )

  it("unchecks signature when agreement is unchecked",
    (done) => {
      renderDOM(html)
      setTimeout(() => {
        const agree1 = document.getElementById(
          "agree1"
        ) as HTMLInputElement
        const sig = document.getElementById(
          "signature"
        ) as HTMLInputElement

        agree1.checked = true
        sig.checked = true

        agree1.checked = false
        agree1.dispatchEvent(new Event("change", {
          bubbles: true
        }))

        expect(sig.checked).toBe(false)
        done()
      })
    }
  )
})
