import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input"]

  declare inputTarget: HTMLInputElement

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

  private replaceCurrentUrl(params: URLSearchParams) {
    const query = params.toString()
    const nextUrl = `${window.location.pathname}${query ? `?${query}` : ""}${window.location.hash}`

    window.history.replaceState({}, "", nextUrl)
  }
}
