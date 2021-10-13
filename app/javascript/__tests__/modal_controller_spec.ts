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
          <div class="modal-content" role="dialog" data-modal-target="dialog openOnLoad">Modal</div>
        </div>`)
    })

    it("opens the modal", () => {
      const modal = document.getElementById("modal")

      expect(modal.classList.contains("visible")).toBe(true)
      expect(modal.getAttribute('aria-hidden')).toEqual("false")
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
      expect(modal.getAttribute('aria-hidden')).toEqual("false")
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
      expect(modal.getAttribute('aria-hidden')).toEqual("true")
    })
  })
})
