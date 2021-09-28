import { Controller } from "stimulus"

export default class extends Controller {
  static targets = [ "destination" ]

  declare destinationTarget: Element

  copy(e: Event) {
    const source = e.currentTarget as HTMLElement
    this.destinationTarget.value = source.value || source.textContent
  }
}

