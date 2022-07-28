import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["amenitiesDiv", "amenityRadioBtn", "maxImage", "minImage"]
  declare amenitiesDivTarget: HTMLDivElement
  declare amenityRadioBtnTarget: HTMLInputElement
  declare maxImageTarget: HTMLInputElement
  declare minImageTarget: HTMLInputElement
  declare amenityRadioBtnTargets: any

  connect(): void {
      const checked = this.isChecked()
      this.amenitiesDivTarget.style.display = checked ? "block" : "none"
      this.minImageTarget.style.display = checked ? "block" : "none"
      this.maxImageTarget.style.display = checked ? "none" : "block"
    }
    
    toggle(){
      const display = this.amenitiesDivTarget.style.display
      if(!this.isChecked()) {
        this.amenitiesDivTarget.style.display = display === "none" ? "block" : "none";
        this.minImageTarget.style.display = this.amenitiesDivTarget.style.display;
        this.maxImageTarget.style.display = display;
      }
    }
    
    isChecked(){
      return this.amenityRadioBtnTargets.some((target: HTMLInputElement) => target.checked )
    }
  }
  