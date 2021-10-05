import { Application, Controller } from "stimulus"
import ValueProjectionController from "./value_projection_controller"

describe("ValueProjectionController", () => {
  describe("#change", () => {
    beforeEach(() => {
      document.body.innerHTML = `
        <section data-controller="value-projection">
          <div>
            <select id="select" data-action="change->value-projection#change">
              <option value="Personal"/>
              <option value="Business"/>
            </select>
          </div>
          <div id="only-personal">...</div>
          <div id="only-business">...</div>
        </section>`

      const application = Application.start()
      application.register("value-projection", ValueProjectionController)
    })

    it("uses the new value as the 'projected' value attribute", () => {
      const section = document.querySelector("section")
      const select = document.getElementById("select")

      select.value = "Business"
      select.dispatchEvent(new Event("change"));

      expect(section.getAttribute("data-value-projection-projected-value")).toEqual(
        "Business"
      )
    })
  })
})
