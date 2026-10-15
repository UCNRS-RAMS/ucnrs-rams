const matomoPageUrl = () => `${window.location.origin}${window.location.pathname}`

export const setMatomoConsent = (consent) => {
  const hadConsent = window.ramsMatomoConsent === true
  window.ramsMatomoConsent = consent
  if (consent && !hadConsent && window.ramsTurboLoaded) trackMatomoPageView()
}

export const trackMatomoPageView = () => {
  if (!window.ramsMatomoConsent || !window._paq || typeof window._paq.push !== "function") {
    return
  }

  window._paq.push(["setCustomUrl", matomoPageUrl()])
  window._paq.push(["setDocumentTitle", document.title])
  window._paq.push(["trackPageView"])
}

document.addEventListener("turbo:load", () => {
  window.ramsTurboLoaded = true
  trackMatomoPageView()
})
