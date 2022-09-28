import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["arriveOn", "departsOn"]
  declare arriveOnTarget: HTMLInputElement
  declare departsOnTarget: HTMLInputElement

  connect(): void {
    if(this.arriveOnTarget.value == '')
    {
      this.arriveOnTarget.value = document.getElementById("visit_start_date").value
      this.departsOnTarget.value = document.getElementById("visit_end_date").value
      this.arriveOnTarget.dispatchEvent(new Event('change'))
      this.departsOnTarget.dispatchEvent(new Event('change'))
    }
  }
}
