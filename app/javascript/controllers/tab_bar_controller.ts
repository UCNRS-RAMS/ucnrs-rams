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

    const queryParams = (new URLSearchParams(window.location.search));
    if (queryParams.has('selected_tab')) {
      this.updateQueryParam("selected_tab", currentTarget.id);
    }
  }
  
  selectTab({params}) {
    document.querySelector('.visit-menu-bar>li>.active').classList.remove('active')
    document.querySelector(`.visit-menu-bar>li>#${params.id}`).classList.add('active')
  }
  
  updateQueryParam(paramName, paramValue) {
    const urlSearchParams = new URLSearchParams(window.location.search);
    const currentValue = urlSearchParams.get(paramName);

    if (currentValue !== paramValue) {
      urlSearchParams.set(paramName, paramValue);
      const newUrl = `${window.location.pathname}?${urlSearchParams.toString()}`;

      try {
        window.history.pushState({}, "", newUrl);
      } catch (err) {
        console.error("Failed to update URL:", err);
      }
    }
  }
}
