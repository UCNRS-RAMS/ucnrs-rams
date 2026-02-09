import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["tbody", "progress", "count", "total"]
  static values = {
    reserveIds: Array,
    url: String,
  }

  declare tbodyTarget: HTMLTableSectionElement
  declare progressTarget: HTMLElement
  declare countTarget: HTMLElement
  declare totalTarget: HTMLElement
  declare reserveIdsValue: number[]
  declare urlValue: string

  connect() {
    this.fetchAllReserves()
  }

  async fetchAllReserves() {
    const ids = this.reserveIdsValue
    this.totalTarget.textContent = ids.length.toString()
    let loaded = 0

    for (const id of ids) {
      try {
        const response = await fetch(`${this.urlValue}?zotero_id=${id}`, {
          headers: { "Accept": "application/json" },
        })

        if (response.ok) {
          const data = await response.json()
          this.appendRow(data.name, data.pub_count)
        } else {
          this.appendErrorRow(id)
        }
      } catch {
        this.appendErrorRow(id)
      }

      loaded++
      this.countTarget.textContent = loaded.toString()
    }

    this.progressTarget.classList.add("hidden")
  }

  appendRow(name: string, pubCount: string) {
    const row = document.createElement("tr")
    row.innerHTML = `<td>${this.escapeHtml(name)}</td><td>${this.escapeHtml(pubCount || "0")}</td>`
    row.classList.add("fade-in")
    this.tbodyTarget.appendChild(row)
  }

  appendErrorRow(id: number) {
    const row = document.createElement("tr")
    row.innerHTML = `<td class="text-muted">Reserve #${id}</td><td class="text-muted">—</td>`
    row.classList.add("fade-in")
    this.tbodyTarget.appendChild(row)
  }

  escapeHtml(text: string): string {
    const div = document.createElement("div")
    div.textContent = text
    return div.innerHTML
  }
}
