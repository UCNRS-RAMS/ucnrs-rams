import { Application } from "@hotwired/stimulus"
import { renderDOM, clearDOM } from "./support/dom"
import ExclusiveToggleController from "../controllers/exclusive_toggle_controller"

describe("ExclusiveToggleController", () => {
  beforeAll(() => {
    const application = Application.start()
    application.register("exclusive-toggle", ExclusiveToggleController)
  })

  afterEach(() => clearDOM())

  beforeEach(() => {
    renderDOM(`
      <div data-controller="exclusive-toggle">
        <input type="checkbox" id="t1a"
          data-exclusive-toggle-target="toggle1"
          data-action="change->exclusive-toggle#toggle"/>
        <input type="checkbox" id="t1b"
          data-exclusive-toggle-target="toggle1"
          data-action="change->exclusive-toggle#toggle"/>
        <input type="checkbox" id="t2a"
          data-exclusive-toggle-target="toggle2"
          data-action="change->exclusive-toggle#toggle"/>
        <input type="checkbox" id="t2b"
          data-exclusive-toggle-target="toggle2"
          data-action="change->exclusive-toggle#toggle"/>
      </div>`)
  })

  it("unchecks toggle2 when a toggle1 is checked", () => {
    const t1a = document.getElementById("t1a") as HTMLInputElement
    const t2a = document.getElementById("t2a") as HTMLInputElement
    const t2b = document.getElementById("t2b") as HTMLInputElement

    t2a.checked = true
    t2b.checked = true

    t1a.checked = true
    t1a.dispatchEvent(new Event("change", { bubbles: true }))

    expect(t2a.checked).toBe(false)
    expect(t2b.checked).toBe(false)
  })

  it("unchecks toggle1 when a toggle2 is checked", () => {
    const t1a = document.getElementById("t1a") as HTMLInputElement
    const t1b = document.getElementById("t1b") as HTMLInputElement
    const t2a = document.getElementById("t2a") as HTMLInputElement

    t1a.checked = true
    t1b.checked = true

    t2a.checked = true
    t2a.dispatchEvent(new Event("change", { bubbles: true }))

    expect(t1a.checked).toBe(false)
    expect(t1b.checked).toBe(false)
  })

  it("does nothing when a checkbox is unchecked", () => {
    const t1a = document.getElementById("t1a") as HTMLInputElement
    const t2a = document.getElementById("t2a") as HTMLInputElement

    t2a.checked = true
    t1a.checked = false
    t1a.dispatchEvent(new Event("change", { bubbles: true }))

    expect(t2a.checked).toBe(true)
  })
})
