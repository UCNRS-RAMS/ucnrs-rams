import { Autocomplete } from "stimulus-autocomplete"

let resultsId = 0

export default class extends Autocomplete {
  static targets = ["selectionType"]

  commit(selected: HTMLElement) {
    super.commit(selected)

    if (this.hasSelectionTypeTarget) {
      this.selectionTypeTarget.value = selected.dataset.autocompleteSelectionType || ""
      this.selectionTypeTarget.dispatchEvent(new Event("change"))
    }
  }

  clear() {
    super.clear()
    if (this.hasSelectionTypeTarget) this.selectionTypeTarget.value = ""
  }

  connect() {
    super.connect()
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

  syncExpanded() {
    this.inputTarget.setAttribute("aria-expanded", this.resultsShown ? "true" : "false")
    this.element.removeAttribute("aria-expanded")
  }

  clearSelectionType = () => {
    if (this.hasSelectionTypeTarget) this.selectionTypeTarget.value = ""
  }
}
