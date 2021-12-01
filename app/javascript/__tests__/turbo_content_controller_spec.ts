import { Application, Controller } from "@hotwired/stimulus"
import { renderDOM, clearDOM } from "./support/dom"
import TurboContentController from "../controllers/turbo_content_controller"

const waitForPromises = (timeout = 1) =>
  new Promise((r) => setTimeout(r, timeout))

describe("TurboContentController", () => {
  beforeAll(() => {
    const application = Application.start()
    application.register("turbo-content", TurboContentController)
  })

  beforeEach(() => jest.clearAllMocks())

  afterEach(() => clearDOM())

  describe("#change from a select click", () => {
    beforeEach(() => {
      renderDOM(`
        <section data-controller="turbo-content">
          <input type="radio" name="radio" value="one" data-action="change->turbo-content#change"/>
          <input type="radio" name="radio" value="two" checked data-action="change->turbo-content#change"/>
          <turbo-frame
            id="not-real"
            data-pattern="http://nowhere/VALUE"
            data-turbo-content-target="destination"
          />
        </section>`)
    })

    it("sets src from value of the radio input on change", () => {
      const frame = document.getElementById("not-real")
      const input = document.querySelector("input[value='one']")
      input.dispatchEvent(new Event("change"))
      expect(frame.src).toEqual("http://nowhere/one")
    })
  })
})

