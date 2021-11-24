import { Application, Controller } from "@hotwired/stimulus"
import { renderDOM, clearDOM } from "./support/dom"
import ToggleController from "../controllers/toggle_controller"

describe("ToggleController", () => {
  beforeAll(() => {
    const application = Application.start()
    application.register("toggle", ToggleController)
  })

  afterEach(() => clearDOM())

  describe("#toggle", () => {
    beforeEach(() => {
      renderDOM(`
        <section data-controller="toggle">
          <input id="input_one" data-toggle-target="toggle" data-toggle-class="blink" class="one blink"/>
          <input id="input_two" data-toggle-target="toggle" data-toggle-class="blink" class="two"/>
          <a id="one" data-action="click->toggle#toggle">Toggle!</a>
        </section>`)
    })

    it("toggles the presenceof the data-toggle-class name in classList", () => {
      const inputOne = document.getElementById("input_one")
      const inputTwo = document.getElementById("input_two")
      const link = document.getElementById("one")

      link.click()
      expect(inputOne.className).toEqual("one")
      expect(inputTwo.className).toEqual("two blink")

      link.click()
      expect(inputOne.className).toEqual("one blink")
      expect(inputTwo.className).toEqual("two")
    })
  })
})
