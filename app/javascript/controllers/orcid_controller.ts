import { Controller } from "@hotwired/stimulus"

const DRAFT_TTL_MS = 30 * 60 * 1000

type OrcidDraft = {
  savedAt: number
  entries: Array<[string, string]>
}

export default class extends Controller {
  static targets = ["input", "authenticated"]
  static values = { authPath: String, origin: String }

  declare inputTarget: HTMLInputElement
  declare authenticatedTarget: HTMLInputElement
  declare hasAuthenticatedTarget: boolean
  declare authPathValue: string
  declare originValue: string

  private readonly handleFormSubmit = () => this.clearDraft()

  connect() {
    this.inputTarget.form?.addEventListener("submit", this.handleFormSubmit)
    this.pruneExpiredDraft()

    const params = new URLSearchParams(window.location.search)
    const callback = params.get("orcid_callback")

    if (callback !== "1") return

    this.restoreDraft()
    this.markAuthenticated()

    params.delete("orcid_callback")
    params.delete("orcid_auth_error")
    this.replaceCurrentUrl(params)
  }

  disconnect() {
    this.inputTarget.form?.removeEventListener("submit", this.handleFormSubmit)
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

    const entries = Array.from(new FormData(form).entries())
      .filter(([, value]) => typeof value === "string")
      .map(([name, value]) => [name, value] as [string, string])

    window.sessionStorage.setItem(
      this.draftStorageKey(),
      JSON.stringify({ savedAt: Date.now(), entries })
    )
  }

  private restoreDraft() {
    const form = this.inputTarget.form
    const draft = this.readDraft()
    if (!form || !draft) return

    if (this.draftIsExpired(draft.savedAt)) {
      this.clearDraft()
      return
    }

    draft.entries.forEach(([name, value]) => {
      if (name === this.inputTarget.name) return

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

    this.clearDraft()
  }

  private pruneExpiredDraft() {
    const draft = this.readDraft()
    if (!draft) return

    if (this.draftIsExpired(draft.savedAt)) this.clearDraft()
  }

  private markAuthenticated() {
    if (!this.hasAuthenticatedTarget) return

    this.authenticatedTarget.value = "true"
  }

  private clearDraft() {
    window.sessionStorage.removeItem(this.draftStorageKey())
  }

  private readDraft() {
    const serializedDraft = window.sessionStorage.getItem(this.draftStorageKey())
    if (!serializedDraft) return

    try {
      return JSON.parse(serializedDraft) as OrcidDraft
    } catch {
      this.clearDraft()
    }
  }

  private draftStorageKey() {
    return `registration-orcid-draft:${this.normalizedOrigin()}`
  }

  private normalizedOrigin() {
    const rawOrigin = this.originValue || `${window.location.pathname}${window.location.search}${window.location.hash}`
    const url = new URL(rawOrigin, window.location.origin)

    url.searchParams.delete("orcid_callback")
    url.searchParams.delete("orcid_auth_error")

    return `${url.pathname}${url.search}${url.hash}`
  }

  private draftIsExpired(savedAt: number) {
    return Date.now() - savedAt > DRAFT_TTL_MS
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
