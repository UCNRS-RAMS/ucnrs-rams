import { Controller } from "stimulus"

import Rails from "@rails/ujs"

interface State {
  id: number
  name: string
  country_id: number
  code: string
}

export default class extends Controller {
  static get targets() {
    return ['states']
  }

  declare statesTarget: HTMLSelectElement

  handleSelectChange(e: Event) {
    const countrySelect = e.currentTarget as HTMLSelectElement
    const selectedCountryId = countrySelect.options[countrySelect.selectedIndex].value
    const url = countrySelect.dataset.url

    Rails.ajax({
      type: 'get',
      url: `${url}?country_id=${selectedCountryId}`,
      success: (data: any) => this.populateStateSelectOptions(data),
      error: (error: any) => console.log(error)
    })
  }

  populateStateSelectOptions(states: State[]) {
    const statesSelect = this.statesTarget
    this.deleteExistingStateSelectOptions(statesSelect)
    states.forEach(state => statesSelect.appendChild(this.buildStateOptionHtml(state)))
  }

  deleteExistingStateSelectOptions(selectField: HTMLSelectElement) {
    while (selectField.options.length > 0) {
      selectField.remove(0);
    }
  }

  buildStateOptionHtml(state: State) {
    const option = document.createElement('option')
    option.value = `${state.id}`
    option.innerHTML = state.name
    return option
  }
}
