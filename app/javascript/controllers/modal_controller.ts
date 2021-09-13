import { Controller } from "stimulus"

export default class extends Controller {
  connect() {
    this.open()
  }

  open() {
    this.element.classList.add("visible")
  }

  close() {
    this.element.classList.remove("visible")
  }
}
