import { Controller } from 'stimulus'

import Rails from '@rails/ujs'

interface Institution {
  acronym: string
  doi: string
  city: string
  country_id: number
  institution_type: string,
  managing_institution_id?: number
  name: string
  state_id: number
}

export default class extends Controller {
  static get targets() {
    return ['institution']
  }

  static get values() {
    return { url: String }
  }

  declare institutionTarget: HTMLInputElement

  timeout: ReturnType<typeof setTimeout> | null = null;

  handleSearch() {
    const query = this.institutionTarget.value

    if (query.length > 2) {
      this.getInstitutions(this.urlValue, query)
    }
  }

  getInstitutions(url: string, query: string) {
    clearTimeout(this.timeout)

    this.timeout = setTimeout(() => {
      Rails.ajax({
        type: 'get',
        url: `${url}?name=${query}`,
        success: (data: any) => this.displayInstitutions(data),
        error: (error: any) => console.log(error),
      })
    }, 300)
  }

  displayInstitutions(institutions: Institution[]) {
    const institutionsDisplay = document.getElementById('#institutions') as HTMLDivElement
    this.removeChildNodes(institutionsDisplay)
    const ul = document.createElement('ul')

    institutions.forEach(institution => {
      let li = this.buildListItem(institution)
      ul.appendChild(li)
    })

    institutionsDisplay.appendChild(ul)
  }

  buildListItem(institution: Institution) {
    const li = document.createElement('li')
    li.innerText = institution.name
    li.setAttribute('data-action', `click->${this.identifier}#setInstitution`)
    return li
  }

  setInstitution(e: MouseEvent) {
    const selectedInstitution = e.currentTarget as HTMLLIElement
    const institutionsDisplay = document.getElementById('#institutions') as HTMLDivElement
    this.institutionTarget.value = selectedInstitution.innerText

    this.removeChildNodes(institutionsDisplay)
  }

  removeChildNodes(parent: Element) {
    while (parent.firstChild) {
      parent.removeChild(parent.firstChild)
    }
  }
}
