import { Autocomplete } from "stimulus-autocomplete"

let resultsId = 0

export default class extends Autocomplete {
  static targets = ["selectionType"]
  declare selectionTypeTarget: HTMLInputElement
  declare hasSelectionTypeTarget: boolean

  // Keep the selected result's source so the form can distinguish institution IDs from ROR IDs.
  commit(selected: HTMLElement) {
    super.commit(selected)

    if (this.hasSelectionTypeTarget) {
      this.selectionTypeTarget.value = selected.dataset.autocompleteSelectionType || ""
      this.selectionTypeTarget.dispatchEvent(new Event("change"))
    }
  }

  // Clear source metadata whenever the base controller clears the selected ID.
  clear() {
    super.clear()
    if (this.hasSelectionTypeTarget) this.selectionTypeTarget.value = ""
  }

  connect() {
    super.connect()
    // Typing invalidates the prior result type; the base controller clears the hidden ID.
    this.inputTarget.addEventListener("input", this.clearSelectionType)

    if (!this.resultsTarget.id) {
      this.resultsTarget.id = `autocomplete-results-${resultsId++}`
    }
    this.resultsTarget.setAttribute("role", "listbox")

    this.inputTarget.setAttribute("role", "combobox")
    this.inputTarget.setAttribute("aria-controls", this.resultsTarget.id)
    this.inputTarget.setAttribute("aria-autocomplete", "list")

    this.syncExpanded()
  }

  disconnect() {
    // Remove the listener added here before the controller is detached.
    this.inputTarget.removeEventListener("input", this.clearSelectionType)
    super.disconnect()
  }

  open() {
    super.open()
    this.syncExpanded()
  }

  close() {
    super.close()
    this.syncExpanded()
  }

  // Reset scroll to the top so the first, most relevant result is visible when results change.
  replaceResults(html: string) {
    super.replaceResults(html)
    this.resetResultsScroll()
  }

  resetResultsScroll() {
    if (this.hasResultsTarget) {
      this.resultsTarget.scrollTop = 0
    }
    if (this.hasInputTarget) {
      this.inputTarget.removeAttribute("aria-activedescendant")
    }
  }

  syncExpanded() {
    this.inputTarget.setAttribute("aria-expanded", this.resultsShown ? "true" : "false")
    this.element.removeAttribute("aria-expanded")
  }

  // Prevent edits to the query from reusing the previous result's source type.
  clearSelectionType = () => {
    if (this.hasSelectionTypeTarget) this.selectionTypeTarget.value = ""
  }
}
