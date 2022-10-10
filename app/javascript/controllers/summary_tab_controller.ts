import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["textArea", "selectField", "emailDiv", "checkBoxDiv", "approvalMessage"]
  declare textAreaTarget: HTMLInputElement
  declare selectFieldTarget: HTMLInputElement
  declare approvalMessageTarget: HTMLInputElement
  declare emailDivTarget: any
  declare checkBoxDivTarget: any
  
  clearField() {
    this.textAreaTarget.value = '';
  }
  
  approvedStatusEmailMessage() {
    this.textAreaTarget.value = this.approvalMessageTarget.value
  }
  
  toggleEmailDiv() {
    this.emailDivTarget.style = (this.selectFieldTarget.value == "silently_update") ? "display:none" : "display:block"
    this.checkBoxDivTarget.style = (this.selectFieldTarget.value == "silently_update") ? "display:block" : "display:none"
  }
}
