import { Application, Controller } from "@hotwired/stimulus"
import { renderDOM, clearDOM } from "./support/dom"
import CounterController from "../controllers/counter_controller"

describe("CounterController", () => {
  beforeAll(() => {
    const application = Application.start()
    application.register("counter", CounterController)
  })

  afterEach(() => clearDOM())

  beforeEach(() => {
    renderDOM(`
      <section data-controller="counter">
        <input id="output" data-counter-target="output" value="NaN"/>
        <input type="button" id="down" data-action="click->counter#decrement"/>
        <input type="button" id="up" data-action="click->counter#increment"/>
      </section>`)
  })

  describe("#increment and #decrement", () => {
    it("increments and decrements the input's value", () => {
      const output = document.getElementById("output")
      output.value = "3"
      const down = document.getElementById("down")
      const up = document.getElementById("up")

      up.click()
      expect(output.value).toEqual("4")

      down.click()
      down.click()
      expect(output.value).toEqual("2")
    })
  })

  describe("edge cases", () => {
    it("treats NaN as 0", () => {
      const output = document.getElementById("output")
      output.value = "NoN"
      const up = document.getElementById("up")

      up.click()

      expect(output.value).toEqual("1")
    })

    it("does not go below 0", () => {
      const output = document.getElementById("output")
      output.value = "0"
      const down = document.getElementById("down")

      down.click()

      expect(output.value).toEqual("1")
    })
  })
})
