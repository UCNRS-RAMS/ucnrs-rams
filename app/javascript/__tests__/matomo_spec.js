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
    delete window.ramsTurboLoaded
  })

  it("does not track a page before analytics consent", () => {
    setMatomoConsent(false)

    trackMatomoPageView()

    expect(window._paq).toEqual([])
  })

  it("tracks each consented Turbo navigation without its query string or fragment", () => {
    setMatomoConsent(true)

    document.dispatchEvent(new Event("turbo:load"))
    window.history.replaceState({}, "", "/projects/43?secret=other")
    document.title = "Project 43"
    document.dispatchEvent(new Event("turbo:load"))

    expect(window._paq).toEqual([
      ["setCustomUrl", "http://localhost/projects/42"],
      ["setDocumentTitle", "Project 42"],
      ["trackPageView"],
      ["setCustomUrl", "http://localhost/projects/43"],
      ["setDocumentTitle", "Project 43"],
      ["trackPageView"]
    ])
  })

  it("tracks an already-consented initial page only on turbo:load", () => {
    setMatomoConsent(true)

    document.dispatchEvent(new Event("turbo:load"))

    expect(window._paq).toEqual([
      ["setCustomUrl", "http://localhost/projects/42"],
      ["setDocumentTitle", "Project 42"],
      ["trackPageView"]
    ])
  })

  it("tracks a newly accepted consent once after the initial turbo:load", () => {
    document.dispatchEvent(new Event("turbo:load"))

    setMatomoConsent(true)

    expect(window._paq).toEqual([
      ["setCustomUrl", "http://localhost/projects/42"],
      ["setDocumentTitle", "Project 42"],
      ["trackPageView"]
    ])
  })
})
