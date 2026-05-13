import { Application } from "@hotwired/stimulus"
import { renderDOM, clearDOM } from "./support/dom"
import ReserveTagController from "../controllers/reserve_tag_controller"

describe("ReserveTagController", () => {
  beforeAll(() => {
    const application = Application.start()
    application.register("reserve-tag", ReserveTagController)
  })

  afterEach(() => clearDOM())

  describe("#connect", () => {
    it("hides the tagsDiv on connect", (done) => {
      renderDOM(`
        <div data-controller="reserve-tag">
          <input type="checkbox"
            data-reserve-tag-target="tagCheckBox"/>
          <div id="tags" data-reserve-tag-target="tagsDiv"
            style="display:block">
            <form id="form">
              <input type="checkbox" name="tag1"/>
            </form>
          </div>
        </div>`)

      setTimeout(() => {
        const tags = document.getElementById("tags")
        expect(tags.style.display).toEqual("none")
        done()
      })
    })
  })

  describe("#toggle", () => {
    let submitted: boolean

    beforeEach(() => {
      submitted = false
      renderDOM(`
        <div data-controller="reserve-tag">
          <input id="toggle-checkbox" type="checkbox"
            data-reserve-tag-target="tagCheckBox"
            data-action="change->reserve-tag#toggle"/>
          <div id="tags" data-reserve-tag-target="tagsDiv">
            <form id="form">
              <input id="cb1" type="checkbox" name="tag1"/>
              <input id="cb2" type="checkbox" name="tag2"/>
            </form>
          </div>
        </div>`)

      const form = document.getElementById("form") as HTMLFormElement
      form.requestSubmit = () => { submitted = true }
    })

    it("shows tagsDiv when toggled from hidden", (done) => {
      setTimeout(() => {
        const tags = document.getElementById("tags")
        expect(tags.style.display).toEqual("none")

        const toggle = document.getElementById(
          "toggle-checkbox"
        ) as HTMLInputElement
        toggle.checked = true
        toggle.dispatchEvent(
          new Event("change", { bubbles: true })
        )

        expect(tags.style.display).toEqual("block")
        done()
      })
    })

    it("hides tagsDiv when toggled from visible", (done) => {
      setTimeout(() => {
        const tags = document.getElementById("tags")
        const toggle = document.getElementById(
          "toggle-checkbox"
        ) as HTMLInputElement

        // First toggle to show
        toggle.checked = true
        toggle.dispatchEvent(
          new Event("change", { bubbles: true })
        )
        expect(tags.style.display).toEqual("block")

        // Second toggle to hide
        toggle.checked = false
        toggle.dispatchEvent(
          new Event("change", { bubbles: true })
        )
        expect(tags.style.display).toEqual("none")
        done()
      })
    })

    it("resets checkboxes and submits when unchecked", (done) => {
      setTimeout(() => {
        const cb1 = document.getElementById("cb1") as HTMLInputElement
        const cb2 = document.getElementById("cb2") as HTMLInputElement
        cb1.checked = true
        cb2.checked = true

        const toggle = document.getElementById(
          "toggle-checkbox"
        ) as HTMLInputElement

        // First check to show
        toggle.checked = true
        toggle.dispatchEvent(
          new Event("change", { bubbles: true })
        )

        // Then uncheck to trigger reset
        toggle.checked = false
        toggle.dispatchEvent(
          new Event("change", { bubbles: true })
        )

        expect(cb1.checked).toBe(false)
        expect(cb2.checked).toBe(false)
        expect(submitted).toBe(true)
        done()
      })
    })
  })
})
