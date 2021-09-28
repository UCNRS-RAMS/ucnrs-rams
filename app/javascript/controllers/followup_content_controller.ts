import { Controller } from "stimulus"

export default class extends Controller {
  static targets = ["destination"]
  static values = { url: String, length: Number }

  declare destinationTargets: Element[]

  urlPlaceholder = "VALUE"

  valueOfInput(input: HTMLElement) {
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
      this.clear()
      return
    }
    const url = this.generateUrl(value)

    fetch(url).then((response: Response) => {
      if (response.ok) {
        response.text().then((text) => this.populateContent(text))
      } else {
        console.error("Error", response)
      }
    })
  }

  clear() {
    this.populateContent("")
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
