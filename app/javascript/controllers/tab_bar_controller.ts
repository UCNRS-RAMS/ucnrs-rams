import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["tab"]
  declare tabTargets: HTMLElement[]

  changeTab(e: Event) {
    const tab = e.currentTarget as HTMLElement

    this.tabTargets.forEach((tab) => tab.classList.remove("active"))

    tab.classList.add("active")
  }
}
