import { Controller } from 'stimulus'

export default class extends Controller {
  static targets = ['input']

  declare inputTarget: Element

  get calendarController() {
    const calendar = document.querySelector("[data-controller='calendar']")
    return this.application.getControllerForElementAndIdentifier(calendar, 'calendar')
  }

  displayCalendar() {
    this.calendarController.open((date: string) => {
      (this.inputTarget as HTMLInputElement).value = date
    })
  }
}
