import { Application, Controller } from "stimulus"
import { renderDOM, clearDOM } from "./support/dom"
import ValueProjectionController from "../controllers/value_projection_controller"

describe("ValueProjectionController", () => {
  beforeAll(() => {
    const application = Application.start()
    application.register("value-projection", ValueProjectionController)
  })

  afterAll(() => clearDOM())

  describe("#change", () => {
    beforeEach(() => {
      renderDOM(`
        <section data-controller="value-projection">
          <div>
            <select id="select" data-action="change->value-projection#change">
              <option value="Personal"/>
              <option value="Business"/>
            </select>
          </div>
          <div id="only-personal">...</div>
          <div id="only-business">...</div>
        </section>`)
    })

    it("uses the new value as the 'projected' value attribute", () => {
      const section = document.querySelector("section")
      const select = document.getElementById("select")

      select.value = "Business"
      select.dispatchEvent(new Event("change"))

      expect(
        section.getAttribute("data-value-projection-projected-value")
      ).toEqual("Business")
    })
  })
})
