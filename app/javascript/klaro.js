import * as Klaro from "klaro/dist/klaro-no-css"
import { setMatomoConsent, trackMatomoPageView } from "matomo"

const privacyPolicyUrl = "https://ucnature.org/rams-privacy-statement/"

const setupKlaro = () => {
  const matomoTrackingScript = document.querySelector('[data-name="matomo-tracking"]')

  if (!matomoTrackingScript) {
    return
  }

  const config = {
    htmlTexts: true,
    cookieExpiresAfterDays: 30,
    default: false,
    mustConsent: false,
    acceptAll: true,
    hideLearnMore: true,
    translations: {
      en: {
        privacyPolicyUrl,
        consentNotice: {
          description:
            `<h1>Cookie Settings</h1>` +
            `<p>RAMS uses cookies that are necessary for the operation of the service and, with your consent, optional analytics cookies.</p>` +
            `<p>RAMS uses Matomo analytics to help us understand how the service is used and to improve its functionality, performance, and user experience. ` +
            `<a href="${privacyPolicyUrl}" target="_blank" rel="noopener">Our Privacy Statement</a> includes more details about the cookies we use and how we protect your privacy.</p>`
        },
        decline: "Allow only necessary cookies",
        ok: "Allow all cookies",
        purposes: {
          analytics: {
            title: "Analytics"
          }
        }
      }
    },
    services: [
      {
        name: "matomo-tracking",
        default: false,
        translations: {
          zz: {
            title: "Matomo analytics"
          },
          en: {
            description: "Matomo is a self-hosted analytics service used without a RAMS user identifier."
          }
        },
        purposes: ["analytics"],
        cookies: [[/^_pk_.*$/, "/", window.location.hostname]],
        required: false,
        optOut: false,
        callback: (consent) => {
          const hadConsent = window.ramsMatomoConsent === true

          setMatomoConsent(consent)
          if (consent && !hadConsent) window.setTimeout(trackMatomoPageView)
        }
      }
    ]
  }

  window.klaro = Klaro
  window.klaroConfig = config
  Klaro.setup(config)

  document.addEventListener("click", (event) => {
    if (event.target instanceof Element && event.target.closest("[data-klaro-open]")) {
      event.preventDefault()
      Klaro.show()
    }
  })
}

if (document.readyState === "loading") {
  document.addEventListener("DOMContentLoaded", setupKlaro, { once: true })
} else {
  setupKlaro()
}
