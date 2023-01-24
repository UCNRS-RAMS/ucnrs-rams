import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["scrollPosition"]
  declare scrollPositionTarget: HTMLInputElement

  connect(): void {
    this.scroll()
  }

  scroll() {
    this.scrollPositionTarget.scrollIntoView();
  }
}
