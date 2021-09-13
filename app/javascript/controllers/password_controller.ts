import { Controller } from "stimulus"

export default class extends Controller {
  static targets = ["input", "icon"]

  readonly inputTarget: Element
  readonly inputTargets: Element[]
  readonly hasInputTarget: boolean

  readonly iconTarget: Element
  readonly iconTargets: Element[]
  readonly hasIconTarget: boolean

  togglePasswordDisplay() {
    const icon = this.iconTarget as HTMLImageElement
    const input = this.inputTarget as HTMLInputElement
    const iconUrls = JSON.parse(icon.dataset.info)
    const showPasswordUrl = iconUrls.show_url
    const hidePasswordUrl = iconUrls.hide_url

    if (input.value == "") return

    if (input.type == "text") {
      input.type = "password"
      icon.src = hidePasswordUrl
    } else {
      input.type = "text"
      icon.src = showPasswordUrl
    }
  }
}

