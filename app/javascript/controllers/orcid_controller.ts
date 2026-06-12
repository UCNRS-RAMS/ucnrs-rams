import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input"]
  static values = { authPath: String, origin: String }

  declare inputTarget: HTMLInputElement
  declare authPathValue: string
  declare originValue: string

  connect() {
    const params = new URLSearchParams(window.location.search)
    const orcid = params.get("orcid")
    const callback = params.get("orcid_callback")

    if (!orcid || callback !== "1") return

    this.inputTarget.value = orcid
    this.inputTarget.dispatchEvent(new Event("input", { bubbles: true }))
    this.inputTarget.dispatchEvent(new Event("change", { bubbles: true }))

    params.delete("orcid")
    params.delete("orcid_callback")
    params.delete("orcid_auth_error")
    this.replaceCurrentUrl(params)
  }

  startAuth() {
    const form = document.createElement("form")
    form.method = "post"
    form.action = this.authPathValue
    form.style.display = "none"

    this.appendHiddenField(form, "authenticity_token", this.csrfToken())
    this.appendHiddenField(form, "origin", this.originValue || window.location.pathname)

    document.body.appendChild(form)
    form.submit()
  }

  private csrfToken() {
    const token = document.querySelector<HTMLMetaElement>("meta[name='csrf-token']")?.content
    return token || ""
  }

  private appendHiddenField(form: HTMLFormElement, name: string, value: string) {
    const input = document.createElement("input")
    input.type = "hidden"
    input.name = name
    input.value = value
    form.appendChild(input)
  }

  private replaceCurrentUrl(params: URLSearchParams) {
    const query = params.toString()
    const nextUrl = `${window.location.pathname}${query ? `?${query}` : ""}${window.location.hash}`

    window.history.replaceState({}, "", nextUrl)
  }
}
