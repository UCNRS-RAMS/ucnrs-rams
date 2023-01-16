import { Controller } from "@hotwired/stimulus"

export default class extends Controller {

  connect(): void {
    this.scroll()
  }

  scroll() {
    document.getElementById('funding-table').scrollIntoView();
  }
}
