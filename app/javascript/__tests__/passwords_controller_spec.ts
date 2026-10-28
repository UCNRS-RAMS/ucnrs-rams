import { Application } from "@hotwired/stimulus"
import { renderDOM, clearDOM } from "./support/dom"
import PasswordsController from "../controllers/passwords_controller"

describe("PasswordsController", () => {
  beforeAll(() => {
    const application = Application.start()
    application.register("passwords", PasswordsController)
  })

  afterEach(() => clearDOM())

  beforeEach(() => {
    renderDOM(`
      <div data-controller="passwords">
        <input id="password" type="password" data-passwords-target="input" />
        <img id="toggle"
             data-passwords-target="icon"
             data-action="click->passwords#togglePasswordDisplay"
             data-info='{"show_url":"/assets/show-password.svg","hide_url":"/assets/hide-password.svg"}' />
      </div>`)
  })

  it("reveals the password and swaps to the show icon on the first click", () => {
    const input = document.getElementById("password") as HTMLInputElement
    const icon = document.getElementById("toggle") as HTMLImageElement

    icon.click()

    expect(input.type).toEqual("text")
    expect(icon.src).toContain("/assets/show-password.svg")
  })

  it("hides the password and swaps to the hide icon on the second click", () => {
    const input = document.getElementById("password") as HTMLInputElement
    const icon = document.getElementById("toggle") as HTMLImageElement

    icon.click()
    icon.click()

    expect(input.type).toEqual("password")
    expect(icon.src).toContain("/assets/hide-password.svg")
  })
})
