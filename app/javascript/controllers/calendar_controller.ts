import { Controller } from 'stimulus'
import Rails from '@rails/ujs'

export default class extends Controller {
  callback: (date: string) => void = () => { }

  get modalController() {
    const modal = document.getElementById('modal')
    return this.application.getControllerForElementAndIdentifier(modal, 'modal')
  }

  fetchCalendar(e: MouseEvent) {
    e.preventDefault()
    e.stopPropagation()

    const link = e.currentTarget as HTMLLinkElement
    Rails.ajax({
      type: 'get',
      url: link.getAttribute('href'),
      success: (data: any) => this.updateCalendar(data),
      error: (error: any) => console.log(error),
    })
  }

  updateCalendar(data: any) {
    const oldCalendar = document.getElementById('calendar')
    const newCalendar = data.getElementById('calendar')
    oldCalendar.replaceWith(newCalendar)
  }

  open(callback: (date: string) => void) {
    this.modalController.open()

    this.callback = callback
  }

  close() {
    this.modalController.close()
  }

  selectDate(e: MouseEvent) {
    const calendarDay = e.target as HTMLElement
    const selectedDate = calendarDay.closest('td').id

    if (calendarDay.classList.contains('past')) {
      e.preventDefault()
      this.callback("")
    } else {
      const formattedDate = this.formatSelectedDate(selectedDate)
      this.callback(formattedDate)
    }
  }

  formatSelectedDate(date: string) {
    const splitDate = date.split('-')
    splitDate.push(splitDate.shift())
    return splitDate.join('/')
  }
}
