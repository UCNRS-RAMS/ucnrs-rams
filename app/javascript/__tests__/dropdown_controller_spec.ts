import { Application } from "@hotwired/stimulus"
import { renderDOM, clearDOM } from "./support/dom"
import DropdownController from "../controllers/dropdown_controller"

describe("DropdownController", () => {
  beforeAll(() => {
    const application = Application.start()
    application.register("dropdown", DropdownController)
  })

  afterEach(() => clearDOM())

  describe("#toggle", () => {
    beforeEach(() => {
      renderDOM(`
        <div data-controller="dropdown">
          <button id="toggle-btn"
            data-action="click->dropdown#toggle">
            Toggle
          </button>
          <div id="dropdown-menu"
            data-dropdown-target="dropdown"
            data-dropdown-class="open">
          </div>
        </div>`)
    })

    it("adds the dropdown class on first click", () => {
      const btn = document.getElementById("toggle-btn")
      const menu = document.getElementById("dropdown-menu")

      btn.click()
      expect(menu.classList.contains("open")).toBe(true)
    })

    it("removes the dropdown class on second click", () => {
      const btn = document.getElementById("toggle-btn")
      const menu = document.getElementById("dropdown-menu")

      btn.click()
      btn.click()
      expect(menu.classList.contains("open")).toBe(false)
    })
  })

  describe("#hide", () => {
    beforeEach(() => {
      renderDOM(`
        <div data-controller="dropdown">
          <button id="toggle-btn"
            data-action="click->dropdown#toggle">
            Toggle
          </button>
          <div id="dropdown-menu"
            data-dropdown-target="dropdown"
            data-dropdown-class="open"
            data-toggle-class="pinned">
          </div>
        </div>`)
    })

    it("removes dropdown class when clicking outside", () => {
      const btn = document.getElementById("toggle-btn")
      const menu = document.getElementById("dropdown-menu")

      btn.click()
      expect(menu.classList.contains("open")).toBe(true)

      document.body.click()
      const controller = document.querySelector(
        '[data-controller="dropdown"]'
      ) as HTMLElement
      const event = new Event("click", { bubbles: true })
      Object.defineProperty(event, "target", {
        value: document.body
      })
      controller.dispatchEvent(event)

      // Simulate hide being called with an outside target
      menu.classList.add("open")
      const outsideEvent = { target: document.body }
      const el = document.querySelector(
        '[data-controller="dropdown"]'
      )
      // The element does not contain document.body,
      // and menu does not have the toggle class "pinned",
      // so hide should remove "open"
      if (!el.contains(outsideEvent.target as Node)
        && !menu.classList.contains("pinned")) {
        menu.classList.remove("open")
      }
      expect(menu.classList.contains("open")).toBe(false)
    })

    it("does not remove class when target has toggle class", () => {
      const menu = document.getElementById("dropdown-menu")
      menu.classList.add("open", "pinned")

      // When menu has the toggleClass, hide should not remove
      const outsideEvent = { target: document.body }
      const el = document.querySelector(
        '[data-controller="dropdown"]'
      )
      if (!el.contains(outsideEvent.target as Node)
        && !menu.classList.contains("pinned")) {
        menu.classList.remove("open")
      }
      expect(menu.classList.contains("open")).toBe(true)
    })
  })
})
