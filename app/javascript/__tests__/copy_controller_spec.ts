import { Application, Controller } from "@hotwired/stimulus"
import { renderDOM, clearDOM } from "./support/dom"
import CopyController from "../controllers/copy_controller"

describe("CopyController", () => {
  beforeAll(() => {
    const application = Application.start()
    application.register("copy", CopyController)
  })

  afterEach(() => clearDOM())

  describe("#change", () => {
    beforeEach(() => {
      renderDOM(`
        <section data-controller="copy">
          <input id="input_one" data-copy-target="destination"/>
          <input id="input_two" data-copy-target="destination"/>
          <div id="one" data-action="click->copy#copy">Number One</div>
          <div id="two" data-action="click->copy#copy">And the Second</div>
        </section>`)
    })

    it("copies the innerText of the clicked element to the input targets", () => {
      const inputOne = document.getElementById("input_one")
      const inputTwo = document.getElementById("input_two")
      const firstDiv = document.getElementById("one")
      const secondDiv = document.getElementById("two")

      firstDiv.click()
      expect(inputOne.value).toEqual("Number One")
      expect(inputTwo.value).toEqual("Number One")

      secondDiv.click()
      expect(inputOne.value).toEqual("And the Second")
      expect(inputTwo.value).toEqual("And the Second")
    })
  })
})
