declare module "stimulus-autocomplete" {
  import { Controller } from "@hotwired/stimulus"

  export class Autocomplete extends Controller {
    inputTarget: HTMLInputElement
    hiddenTarget: HTMLInputElement
    resultsTarget: HTMLElement
    hasInputTarget: boolean
    hasHiddenTarget: boolean
    hasResultsTarget: boolean
    resultsShown: boolean
    open(): void
    close(): void
  }

  export default Autocomplete
}
