import { Autocomplete } from "stimulus-autocomplete"

let resultsId = 0

export default class extends Autocomplete {
  connect() {
    super.connect()

    if (!this.resultsTarget.id) {
      this.resultsTarget.id = `autocomplete-results-${resultsId++}`
    }
    this.resultsTarget.setAttribute("role", "listbox")

    this.inputTarget.setAttribute("role", "combobox")
    this.inputTarget.setAttribute("aria-controls", this.resultsTarget.id)
    this.inputTarget.setAttribute("aria-autocomplete", "list")

    this.syncExpanded()
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
}
