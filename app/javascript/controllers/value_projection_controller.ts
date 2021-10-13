import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { projected: String }

  change(event) {
    const value: string = event.target.value
    this.projectedValue = value
  }
}
