import { Application } from "@hotwired/stimulus"
import { renderDOM, clearDOM } from "./support/dom"

jest.mock("stimulus-autocomplete", () => {
  const { Controller } = require("@hotwired/stimulus")

  class MockAutocomplete extends Controller {
    static targets = ["input", "hidden", "results"]
    declare inputTarget: HTMLInputElement
    declare hiddenTarget: HTMLInputElement
    declare resultsTarget: HTMLElement
    declare hasInputTarget: boolean
    declare hasHiddenTarget: boolean
    declare hasResultsTarget: boolean

    connect() {
      this.close()
    }

    open() {
      if (this.hasResultsTarget) {
        this.resultsTarget.hidden = false
      }
    }

    close() {
      if (this.hasResultsTarget) {
        this.resultsTarget.hidden = true
      }
      if (this.hasInputTarget) {
        this.inputTarget.removeAttribute("aria-activedescendant")
      }
    }

    get resultsShown() {
      return this.hasResultsTarget ? !this.resultsTarget.hidden : false
    }

    set resultsShown(val: boolean) {
      if (this.hasResultsTarget) {
        this.resultsTarget.hidden = !val
      }
    }

    replaceResults(html: string) {
      this.resultsTarget.innerHTML = html
      if (this.resultsTarget.children.length > 0) {
        this.open()
      } else {
        this.close()
      }
    }

    commit(selected: HTMLElement) {
      const textValue = selected.getAttribute("data-autocomplete-label") || selected.textContent?.trim() || ""
      const value = selected.getAttribute("data-autocomplete-value") || textValue
      this.inputTarget.value = textValue
      if (this.hasHiddenTarget) {
        this.hiddenTarget.value = value
      }
    }

    clear() {
      this.inputTarget.value = ""
      if (this.hasHiddenTarget) {
        this.hiddenTarget.value = ""
      }
    }
  }

  return {
    __esModule: true,
    Autocomplete: MockAutocomplete,
    default: MockAutocomplete,
  }
})

import AutocompleteController from "../controllers/autocomplete_controller"

const waitForPromises = (timeout = 10) =>
  new Promise((r) => setTimeout(r, timeout))

describe("AutocompleteController", () => {
  let application: Application

  beforeAll(() => {
    application = Application.start()
    application.register("autocomplete", AutocompleteController)
  })

  afterEach(() => clearDOM())

  const renderAutocomplete = async (initialResultsHtml = "") => {
    renderDOM(`
      <div class="field autocomplete" data-controller="autocomplete" data-autocomplete-url-value="/search">
        <input type="text" data-autocomplete-target="input" />
        <input type="hidden" data-autocomplete-target="hidden" />
        <input type="hidden" data-autocomplete-target="selectionType" />
        <div class="autocomplete-results-container">
          <ul class="autocomplete-results" data-autocomplete-target="results">${initialResultsHtml}</ul>
        </div>
      </div>
    `)

    await waitForPromises()

    const container = document.querySelector('[data-controller="autocomplete"]') as HTMLElement
    const controller = application.getControllerForElementAndIdentifier(
      container,
      "autocomplete"
    ) as AutocompleteController

    return { container, controller }
  }

  describe("#connect", () => {
    it("sets ARIA attributes on input and results targets", async () => {
      const { controller } = await renderAutocomplete()
      const input = controller.inputTarget
      const results = controller.resultsTarget

      expect(input.getAttribute("role")).toBe("combobox")
      expect(input.getAttribute("aria-autocomplete")).toBe("list")
      expect(input.getAttribute("aria-controls")).toBe(results.id)
      expect(input.getAttribute("aria-expanded")).toBe("false")
      expect(results.getAttribute("role")).toBe("listbox")
    })
  })

  describe("#replaceResults", () => {
    it("resets scrollTop of resultsTarget to 0 when new results are rendered", async () => {
      const initialItems = Array.from({ length: 20 }, (_, i) =>
        `<li role="option" id="opt-${i}" data-autocomplete-value="${i}" data-autocomplete-label="Item ${i}">Item ${i}</li>`
      ).join("")

      const { controller } = await renderAutocomplete(initialItems)
      const results = controller.resultsTarget

      // Simulate the user scrolling down the results list
      results.scrollTop = 150
      expect(results.scrollTop).toBe(150)

      // Replace results with new items
      const newItems = `
        <li role="option" data-autocomplete-value="99" data-autocomplete-label="New Best Match">New Best Match</li>
        <li role="option" data-autocomplete-value="100" data-autocomplete-label="Second Match">Second Match</li>
      `
      controller.replaceResults(newItems)

      expect(results.scrollTop).toBe(0)
    })

    it("clears aria-activedescendant from inputTarget on new results", async () => {
      const { controller } = await renderAutocomplete()
      const input = controller.inputTarget

      input.setAttribute("aria-activedescendant", "previous-option-id")
      expect(input.getAttribute("aria-activedescendant")).toBe("previous-option-id")

      const newItems = `<li role="option" data-autocomplete-value="1" data-autocomplete-label="Match">Match</li>`
      controller.replaceResults(newItems)

      expect(input.hasAttribute("aria-activedescendant")).toBe(false)
    })

    it("updates aria-expanded when results are populated", async () => {
      const { controller } = await renderAutocomplete()
      const input = controller.inputTarget

      expect(input.getAttribute("aria-expanded")).toBe("false")

      const newItems = `<li role="option" data-autocomplete-value="1" data-autocomplete-label="Match">Match</li>`
      controller.replaceResults(newItems)

      expect(input.getAttribute("aria-expanded")).toBe("true")
    })
  })

  describe("#commit", () => {
    it("updates selectionTypeTarget and dispatches a change event", async () => {
      const { controller } = await renderAutocomplete(`
        <li role="option" id="item-1" data-autocomplete-value="42" data-autocomplete-label="UC Berkeley" data-autocomplete-selection-type="ror">UC Berkeley</li>
      `)

      const selectionType = controller.selectionTypeTarget
      const changeHandler = jest.fn()
      selectionType.addEventListener("change", changeHandler)

      const option = document.getElementById("item-1") as HTMLElement
      controller.commit(option)

      expect(selectionType.value).toBe("ror")
      expect(changeHandler).toHaveBeenCalledTimes(1)
    })
  })

  describe("#clear", () => {
    it("clears selectionTypeTarget", async () => {
      const { controller } = await renderAutocomplete()
      controller.selectionTypeTarget.value = "custom"

      controller.clear()

      expect(controller.selectionTypeTarget.value).toBe("")
    })
  })

  describe("typing in inputTarget", () => {
    it("clears selectionTypeTarget value on input event", async () => {
      const { controller } = await renderAutocomplete()
      controller.selectionTypeTarget.value = "custom"

      controller.inputTarget.dispatchEvent(new Event("input"))

      expect(controller.selectionTypeTarget.value).toBe("")
    })
  })
})
