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
    commit(selected: HTMLElement): void
    clear(): void
    open(): void
    close(): void
    replaceResults(html: string): void
  }

  export default Autocomplete
}
