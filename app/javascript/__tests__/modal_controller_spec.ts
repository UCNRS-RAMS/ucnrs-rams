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

      setTimeout(() => {
        try {
          expect(triggerFn).toHaveBeenCalled()
          expect(root.classList.contains("visible")).toBe(true)
          expect(root.getAttribute("aria-hidden")).toBe("false")
        } finally {
          done()
        }
      })
    })

    it("should not be called if the element isn't openOnLoad", (done) => {
      const root = document.querySelectorAll("body > *")[0]

      root.innerHTML = `<div data-modal-target="dialog"/>`

      setTimeout(() => {
        try {
          expect(root.classList.contains("visible")).toBe(false)
          expect(root.getAttribute("aria-hidden")).toBe("true")
        } finally {
          done()
        }
      })
    })
  })

  describe("openOnLoadTargetDisconnected", () => {
    beforeEach(() => {
      renderDOM(`
        <div id="modal" class="modal" data-controller="modal" aria-hidden="true">
          <div data-modal-target="dialog openOnLoad"/>
        </div>`)
    })

    it("closes the modal", (done) => {
      const root = document.querySelectorAll("body > *")[0]
      const triggerFn = jest.spyOn(root.modal, "openOnLoadTargetDisconnected")

      root.innerHTML = ``

      setTimeout(() => {
        try {
          expect(triggerFn).toHaveBeenCalled()
          expect(root.classList.contains("visible")).toBe(false)
          expect(root.getAttribute("aria-hidden")).toBe("true")
        } finally {
          done()
        }
      })
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
          <button id="closeAndContinue" data-action="click->modal#closeAndContinue">Close</button>
        </div>`)
    })

    it("closes the modal", () => {
      const closeButton = document.getElementById("close")
      const modal = document.getElementById("modal")
      const event = new MouseEvent("click")
      const propagationFn = jest.spyOn(event, "stopPropagation")

      closeButton.dispatchEvent(event)

      closeButton.click()

      expect(modal.classList.contains("visible")).toBe(false)
      expect(modal.getAttribute("aria-hidden")).toEqual("true")
      expect(propagationFn).toHaveBeenCalled()
    })

    it("closes the modal without stopping propagation", () => {
      const closeButton = document.getElementById("closeAndContinue")
      const modal = document.getElementById("modal")
      const event = new MouseEvent("click")
      const propagationFn = jest.spyOn(event, "stopPropagation")

      closeButton.dispatchEvent(event)

      expect(modal.classList.contains("visible")).toBe(false)
      expect(modal.getAttribute("aria-hidden")).toEqual("true")
      expect(propagationFn).not.toHaveBeenCalled()
    })
  })

  describe("focus management", () => {
    beforeEach(() => {
      renderDOM(`
        <a id="trigger" href="#">Open</a>
        <div id="modal" class="modal" data-controller="modal" aria-hidden="true">
          <div id="dialog" data-modal-target="dialog">
            <input id="field" />
          </div>
        </div>`)
    })

    it("moves focus to the dialog when it opens", () => {
      document.getElementById("trigger").focus()

      document.getElementById("modal").modal.open()

      expect(document.activeElement).toBe(document.getElementById("dialog"))
    })

    it("leaves focus alone when it is already inside the dialog", () => {
      const field = document.getElementById("field")
      field.focus()

      document.getElementById("modal").modal.open()

      expect(document.activeElement).toBe(field)
    })

    it("returns focus to the element that opened the modal when it closes", () => {
      const trigger = document.getElementById("trigger")
      const modal = document.getElementById("modal")
      trigger.focus()

      modal.modal.open()
      modal.modal.close()

      expect(document.activeElement).toBe(trigger)
    })

    it("does not move focus when closing a modal that never opened", () => {
      const field = document.getElementById("field")
      field.focus()

      document.getElementById("modal").modal.close()

      expect(document.activeElement).toBe(field)
    })
  })

  describe("#closeOnEscape", () => {
    const modalHTML = (visible: boolean) => `
      <div id="modal" class="modal ${visible ? "visible" : ""}" data-controller="modal"
        data-action="keydown.esc@window->modal#closeOnEscape" aria-hidden="${!visible}">
        <div class="modal-content" role="dialog" data-modal-target="dialog">Modal</div>
      </div>`

    describe("when the modal is visible", () => {
      beforeEach(() => renderDOM(modalHTML(true)))

      it("closes the modal when Escape is pressed", () => {
        const modal = document.getElementById("modal")

        window.dispatchEvent(new KeyboardEvent("keydown", { key: "Escape" }))

        expect(modal.classList.contains("visible")).toBe(false)
        expect(modal.getAttribute("aria-hidden")).toEqual("true")
        expect(modal.hasAttribute("inert")).toBe(true)
      })

      it("ignores other keys", () => {
        const modal = document.getElementById("modal")

        window.dispatchEvent(new KeyboardEvent("keydown", { key: "Enter" }))

        expect(modal.classList.contains("visible")).toBe(true)
      })
    })

    describe("when the modal is not visible", () => {
      beforeEach(() => renderDOM(modalHTML(false)))

      it("does nothing when Escape is pressed", () => {
        const modal = document.getElementById("modal")
        const closeFn = jest.spyOn(modal.modal, "close")

        window.dispatchEvent(new KeyboardEvent("keydown", { key: "Escape" }))

        expect(closeFn).not.toHaveBeenCalled()
      })
    })
  })
})
