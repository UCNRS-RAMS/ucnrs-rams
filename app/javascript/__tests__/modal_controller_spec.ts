import { Application, Controller } from "@hotwired/stimulus"
import { renderDOM, clearDOM } from "./support/dom"
import ModalController from "../controllers/modal_controller"

describe("ModalController", () => {
  beforeAll(() => {
    const application = Application.start()
    application.register("modal", ModalController)
  })

  afterEach(() => clearDOM())

  describe("#connect", () => {
    beforeEach(() => {
      renderDOM(`
        <div id="modal" class="modal" data-controller="modal" aria-hidden="true">
        </div>`)
    })

    it("puts an instance of the controller onto the element", () => {
      const root = document.querySelectorAll("body > *")[0]

      expect(root.modal).not.toBeNull()
    })
  })

  describe("openOnLoadTargetConnected", () => {
    beforeEach(() => {
      renderDOM(`
        <div id="modal" class="modal" data-controller="modal" aria-hidden="true">
        </div>`)
    })

    it("opens the modal", (done) => {
      const root = document.querySelectorAll("body > *")[0]
      const triggerFn = jest.spyOn(root.modal, "openOnLoadTargetConnected")

      root.innerHTML = `<div data-modal-target="dialog openOnLoad"/>`

      setTimeout(() => { try {
        expect(triggerFn).toHaveBeenCalled()
        expect(root.classList.contains("visible")).toBe(true)
        expect(root.getAttribute("aria-hidden")).toBe("false")
      } finally {
        done()
      }})
    })

    it("should not be called if the element isn't openOnLoad", (done) => {
      const root = document.querySelectorAll("body > *")[0]

      root.innerHTML = `<div data-modal-target="dialog"/>`

      setTimeout(() => { try {
        expect(root.classList.contains("visible")).toBe(false)
        expect(root.getAttribute("aria-hidden")).toBe("true")
      } finally {
        done()
      }})
    })
  })

  describe("#open", () => {
    beforeEach(() => {
      renderDOM(`
        <div id="modal" class="modal" data-controller="modal" aria-hidden="true">
          <div class="modal-content" role="dialog" data-modal-target="dialog">Modal</div>
          <button id="open" data-action="click->modal#open">Open</button>
        </div>`)
    })

    it("opens the modal", () => {
      const openButton = document.getElementById("open")
      const modal = document.getElementById("modal")

      openButton.click()

      expect(modal.classList.contains("visible")).toBe(true)
      expect(modal.getAttribute("aria-hidden")).toEqual("false")
    })
  })

  describe("#close", () => {
    beforeEach(() => {
      renderDOM(`
        <div id="modal" class="modal visible" data-controller="modal" aria-hidden="false">
          <div class="modal-content" role="dialog" data-modal-target="dialog">Modal</div>
          <button id="close" data-action="click->modal#close">Close</button>
        </div>`)
    })

    it("closes the modal", () => {
      const closeButton = document.getElementById("close")
      const modal = document.getElementById("modal")

      closeButton.click()

      expect(modal.classList.contains("visible")).toBe(false)
      expect(modal.getAttribute("aria-hidden")).toEqual("true")
    })
  })
})
