import { Application, Controller } from "stimulus"
import CopyController from "./copy_controller"

describe("CopyController", () => {
  describe("#change", () => {
    beforeEach(() => {
      document.body.innerHTML = `
        <section data-controller="copy">
          <input id="input" data-copy-target="destination"/>
          <div id="one" data-action="click->copy#copy">Number One</div>
          <div id="two" data-action="click->copy#copy">And the Second</div>
        </section>`

      const application = Application.start()
      application.register("copy", CopyController)
    })

    it("copies the innerText of the clicked element to the input", () => {
      const input = document.getElementById("input")
      const firstDiv = document.getElementById("one")
      const secondDiv = document.getElementById("two")

      firstDiv.click()
      expect(input.value).toEqual("Number One")

      secondDiv.click()
      expect(input.value).toEqual("And the Second")
    })
  })
})

