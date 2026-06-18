import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "authenticated"]
  static values = { authPath: String, origin: String }

  declare inputTarget: HTMLInputElement
  declare authenticatedTarget: HTMLInputElement
  declare hasAuthenticatedTarget: boolean
  declare authPathValue: string
  declare originValue: string

  connect() {
    const params = new URLSearchParams(window.location.search)
    const callback = params.get("orcid_callback")

    if (callback !== "1") return

    this.restoreDraft()
    this.markAuthenticated()

    params.delete("orcid_callback")
    params.delete("orcid_auth_error")
    this.replaceCurrentUrl(params)
  }

  startAuth() {
    this.persistDraft()

    const form = document.createElement("form")
    form.method = "post"
    form.action = this.authPathValue
    form.style.display = "none"

    this.appendHiddenField(form, "authenticity_token", this.csrfToken())
    this.appendHiddenField(form, "origin", this.originValue || window.location.pathname)

    document.body.appendChild(form)
    form.submit()
  }

  private persistDraft() {
    const form = this.inputTarget.form
    if (!form) return

    const draft = Array.from(new FormData(form).entries())
    window.sessionStorage.setItem(this.draftStorageKey(), JSON.stringify(draft))
  }

  private restoreDraft() {
    const form = this.inputTarget.form
    const serializedDraft = window.sessionStorage.getItem(this.draftStorageKey())
    if (!form || !serializedDraft) return

    const draftEntries: [string, FormDataEntryValue][] = JSON.parse(serializedDraft)
    draftEntries.forEach(([name, value]) => {
      if (name === this.inputTarget.name) return
      if (typeof value !== "string") return

      const escapedName = this.escapeAttributeSelector(name)
      const fields = form.querySelectorAll<HTMLInputElement | HTMLSelectElement | HTMLTextAreaElement>(`[name="${escapedName}"]`)

      fields.forEach((field) => {
        if (field instanceof HTMLInputElement && field.type === "radio") {
          field.checked = field.value === value
          if (field.checked) field.dispatchEvent(new Event("change", { bubbles: true }))
          return
        }

        if (field instanceof HTMLInputElement && field.type === "checkbox") {
          field.checked = true
          field.dispatchEvent(new Event("change", { bubbles: true }))
          return
        }

        field.value = value
        field.dispatchEvent(new Event("input", { bubbles: true }))
        field.dispatchEvent(new Event("change", { bubbles: true }))
      })
    })

    window.sessionStorage.removeItem(this.draftStorageKey())
  }

  private markAuthenticated() {
    if (!this.hasAuthenticatedTarget) return

    this.authenticatedTarget.value = "true"
  }

  private draftStorageKey() {
    return "registration-orcid-draft"
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

  private escapeAttributeSelector(value: string) {
    return value.replace(/\\/g, "\\\\").replace(/"/g, "\\\"")
  }
}
