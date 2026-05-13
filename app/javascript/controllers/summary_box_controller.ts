import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  alertMessage(event: Event & { params: { staffMember: boolean, visitId: string } }) {
    const { staffMember, visitId } = event.params
    let preventDefault = false;

    if(staffMember) {
      let confirmed = confirm(
        `You are about to delete visit # ${visitId}` +
        ` and all Invoices attached to this visit.`
      )
      preventDefault = !confirmed
    }
    else {
      alert(
        "You are not allowed to delete visits" +
        " from reserves you do not administrate."
      )
      preventDefault = true
    }

    if(preventDefault) {
      event.stopImmediatePropagation()
      event.preventDefault()
    }
  }
}
