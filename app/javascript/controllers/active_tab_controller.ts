import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["tab"]
  static values = { selected: Number }
  
  declare tabTargets: any
  declare selectedValue: any
  
  connect(): void {
    this.tabTargets[this.selectedValue].classList.add('active')
  }
  
  activeCalendar(event){
    this.tabTargets[this.selectedValue].classList.remove('active')
    this.selectedValue = event.target.closest('a').attributes['data-index'].value
    this.tabTargets[this.selectedValue].classList.add('active')
  }
}
