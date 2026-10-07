import {
  setMatomoConsent,
  trackMatomoPageView
} from "../matomo"

describe("Matomo page tracking", () => {
  beforeEach(() => {
    window._paq = []
    window.history.replaceState({}, "", "/projects/42?access_token=secret#details")
    document.title = "Project 42"
  })

  afterEach(() => {
    delete window._paq
    delete window.ramsMatomoConsent
  })

  it("does not track a page before analytics consent", () => {
    setMatomoConsent(false)

    trackMatomoPageView()

    expect(window._paq).toEqual([])
  })

  it("tracks a consented Turbo page without its query string or fragment", () => {
    setMatomoConsent(true)

    document.dispatchEvent(new Event("turbo:load"))

    expect(window._paq).toEqual([
      ["setCustomUrl", "http://localhost/projects/42"],
      ["setDocumentTitle", "Project 42"],
      ["trackPageView"]
    ])
  })
})
