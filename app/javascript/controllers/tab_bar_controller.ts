import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["tab"]
  declare tabTargets: HTMLElement[]

  changeTab(e: Event) {
    const currentTarget = e.currentTarget as HTMLElement

    this.tabTargets.forEach((tab) => tab.classList.remove("active"))

    if (currentTarget.dataset.tabBarId) {
      document.getElementById(currentTarget.dataset.tabBarId).classList.add("active")
    }
    else {
      currentTarget.classList.add("active")
    }
  }
  
  selectSummaryTab() {
    document.querySelector('.visit-menu-bar>li>.nav-link.active').classList.remove('active')
    document.querySelector('.visit-menu-bar>li>.nav-link').classList.add('active')
  }
}
