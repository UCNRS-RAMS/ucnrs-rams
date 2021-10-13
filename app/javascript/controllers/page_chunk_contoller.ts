import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["chunk"]

  static values = {
    url: String,
    length: { type: Number, default: 0 },
  }
  declare urlValue: string
  declare lengthValue: number

  declare chunkTargets: HTMLElement[]

  urlPlaceholder = "VALUE"

  async change(e: Event) {
    const value = (e.currentTarget as HTMLInputElement).value
    if (String(value).length < this.lengthValue) {
      this.clearAllContent()
      return
    }

    try {
      const response = await this.loadContent(value)
      const content = await this.extractContent(reponse)
      this.chunkTargets.forEach((chunk) => {
        this.populateContent(content, chunk)
      })
    } catch (e) {
      this.clearAllContent()
    }
  }

  loadContent(target: HTMLElement, value: string): Promise<string> {
    const urlPattern = target.dataset.followupContentUrlValue
    const url = this.generateUrl(value)

    fetch(url).then((response: Response) => {
      if (response.ok) {
        return response.text()
      } else {
        return Promise.reject(`Error ${response.code}`)
      }
    })
  }

  generateUrl(value: string) {
    return this.urlValue.replace(this.urlPlaceholder, value)
  }

  clearAllContent() {
    this.destinationTargets.forEach((target) => {
      this.clearContent(target)
    })
  }

  clearContent(target: HTMLElement) {
    this.populateContent("", target)
  }

  populateContent(data: string, target: HTMLElement) {
    target.innerHTML = data
  }
}
