import { Controller } from "stimulus"

export default class extends Controller {
  static targets = ["destination"]
  static values = { url: String }

  declare destinationTargets: Element[]

  urlPlaceholder = "VALUE"

  change(e: Event) {
    const sourceInput = e.currentTarget as HTMLSelectElement
    const sourceValue = sourceInput.options[sourceInput.selectedIndex].value
    const url = this.generateUrl(sourceValue)

    fetch(url).then((response: Response) => {
      if (response.ok) {
        response.text().then(text => this.populateContent(text))
      } else {
        console.error("Error", response)
      }
    })
  }

  generateUrl(value: string) {
    return this.urlValue.replace(this.urlPlaceholder, value)
  }

  populateContent(data: string) {
    this.destinationTargets.forEach((target) => {
      target.innerHTML = data
    })
  }
}
