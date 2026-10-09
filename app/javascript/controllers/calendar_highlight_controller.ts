import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["entry"]

  declare entryTargets: HTMLElement[]

  highlight(event: Event) {
    const wrap = event.currentTarget as HTMLElement
    const entryId = wrap.dataset.entryId
    const visitId = wrap.dataset.visitId
    if (!entryId || !visitId) return

    this.entryTargets.forEach((el) => {
      if (el.dataset.entryId === entryId) {
        el.classList.add("cal-highlight", "cal-primary")
      }
      if (el.dataset.visitId !== visitId) {
        el.classList.add("cal-muted")
      }
    })
  }

  unhighlight(event: Event) {
    const wrap = event.currentTarget as HTMLElement
    const entryId = wrap.dataset.entryId
    if (!entryId) return

    this.entryTargets.forEach((el) => {
      if (el.dataset.entryId === entryId) {
        el.classList.remove("cal-highlight", "cal-primary")
      }
      el.classList.remove("cal-muted")
    })
  }
}
