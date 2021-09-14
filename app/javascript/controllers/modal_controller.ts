import { Controller } from "stimulus"

export default class extends Controller {
  connect() {
    this.open()
  }

  open() {
    this.element.classList.add("visible")
    this.element.setAttribute("aria-hidden", "false")
    document.getElementsByTagName("main")[0].setAttribute("aria-hidden", "true")
  }

  close() {
    this.element.classList.remove("visible")
    this.element.setAttribute("aria-hidden", "true")
    document.getElementsByTagName("main")[0].setAttribute("aria-hidden", "false")
  }
}
