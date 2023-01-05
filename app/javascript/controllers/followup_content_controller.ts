import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["destination", "checkbox", "billingAddress"]

  static values = { length: Number }
  declare lengthValue: number

  declare destinationTargets: HTMLElement[]
  declare checkboxTarget: HTMLFormElement
  declare billingAddressTarget: HTMLFormElement


  urlPlaceholder = "VALUE"

  valueOfInput(input: HTMLElement): string {
    if (input.tagName == "SELECT") {
      const element = input as HTMLSelectElement
      return element.options[element.selectedIndex].value
    } else {
      const element = input as HTMLInputElement
      return input.value
    }
  }

  change(e: Event) {
    const value = this.valueOfInput(e.currentTarget as HTMLElement)
    if (String(value).length < this.lengthValue) {
      this.clearAllContent()
      return
    }

    this.destinationTargets.forEach((target) => this.loadContent(target, value))
  }

  toggle(){
    this.checkboxTarget.checked ? this.billingAddressTarget.setAttribute("hidden", "true" ) : this.billingAddressTarget.removeAttribute("hidden")
  }

  loadContent(target: HTMLElement, value: string) {
    const urlPattern = target.dataset.followupContentUrlValue;
    const url = this.generateUrl(urlPattern, value)

    fetch(url).then((response: Response) => {
      if (response.ok) {
        response.text().then((text) => this.populateContent(target, text))
      } else {
        this.clearContent(target)
        console.error("Error", response)
      }
    })
  }

  generateUrl(pattern: string, value: string) {
    return pattern.replace(this.urlPlaceholder, value)
  }

  clearAllContent() {
    this.destinationTargets.forEach((target) => {
      this.clearContent(target)
    })
  }

  clearContent(target: HTMLElement) {
    this.populateContent(target, "")
  }

  populateContent(target: HTMLElement, data: string) {
    target.innerHTML = data
  }
}
