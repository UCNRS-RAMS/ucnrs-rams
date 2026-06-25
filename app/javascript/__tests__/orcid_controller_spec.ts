import { Application } from "@hotwired/stimulus"
import { afterEach, beforeAll, beforeEach, describe, expect, it, jest } from "@jest/globals"
import OrcidController from "../controllers/orcid_controller"
import { clearDOM, renderDOM } from "./support/dom"

describe("OrcidController", () => {
  beforeAll(() => {
    const application = Application.start()
    application.register("orcid", OrcidController)
  })

  beforeEach(() => {
    window.sessionStorage.clear()
    window.history.replaceState({}, "", "/users/edit")
  })

  afterEach(() => clearDOM())

  const flush = () => new Promise((resolve) => setTimeout(resolve, 0))

  const renderForm = (originValue = "/users/edit") => {
    renderDOM(`
      <div data-controller="orcid"
           data-orcid-auth-path-value="/users/auth/orcid"
           data-orcid-origin-value="${originValue}">
        <form id="orcid_form">
          <input id="user_first_name" name="user[first_name]" value="Jane" />
          <input id="user_orcid" name="user[orcid]" data-orcid-target="input" value="0000-0002-1825-0097" />
          <input id="user_orcid_authenticated" name="user[orcid_authenticated]" data-orcid-target="authenticated" value="false" />
          <button type="button" data-action="orcid#startAuth">Connect</button>
        </form>
      </div>
    `)
  }

  it("stores a draft under the normalized origin when auth starts", async () => {
    renderForm("/users/edit?tab=profile&orcid_callback=1")
    const submitSpy = jest.spyOn(HTMLFormElement.prototype, "submit").mockImplementation(() => {})

    await flush()

    ;(document.querySelector("button[data-action='orcid#startAuth']") as HTMLButtonElement).click()

    const key = "registration-orcid-draft:/users/edit?tab=profile"
    const draft = JSON.parse(window.sessionStorage.getItem(key)!)

    expect(submitSpy).toHaveBeenCalled()
    expect(draft.savedAt).toEqual(expect.any(Number))
    expect(draft.entries).toContainEqual(["user[first_name]", "Jane"])
    expect(draft.entries).toContainEqual(["user[orcid]", "0000-0002-1825-0097"])
    expect(draft.entries).toContainEqual(["user[orcid_authenticated]", "false"])

    submitSpy.mockRestore()
  })

  it("restores and clears the draft after the ORCID callback", async () => {
    window.history.replaceState({}, "", "/users/edit?orcid_callback=1")
    window.sessionStorage.setItem(
      "registration-orcid-draft:/users/edit",
      JSON.stringify({
        savedAt: Date.now(),
        entries: [
          ["user[first_name]", "Jane"],
          ["user[orcid]", "0000-0002-1825-0097"],
          ["user[orcid_authenticated]", "false"],
        ],
      })
    )

    renderForm("/users/edit")

    await flush()

    expect((document.getElementById("user_first_name") as HTMLInputElement).value).toEqual("Jane")
    expect((document.getElementById("user_orcid") as HTMLInputElement).value).toEqual("0000-0002-1825-0097")
    expect((document.getElementById("user_orcid_authenticated") as HTMLInputElement).value).toEqual("true")
    expect(window.sessionStorage.getItem("registration-orcid-draft:/users/edit")).toBeNull()
    expect(window.location.search).toEqual("")
  })

  it("clears the draft when the form is submitted normally", async () => {
    renderForm()
    window.sessionStorage.setItem(
      "registration-orcid-draft:/users/edit",
      JSON.stringify({
        savedAt: Date.now(),
        entries: [["user[orcid]", "0000-0002-1825-0097"]],
      })
    )

    await flush()

    const form = document.getElementById("orcid_form") as HTMLFormElement
    form.dispatchEvent(new Event("submit", { bubbles: true, cancelable: true }))

    expect(window.sessionStorage.getItem("registration-orcid-draft:/users/edit")).toBeNull()
  })
})

