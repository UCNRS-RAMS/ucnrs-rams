import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["tbody", "progress", "count", "total", "itemType"]
  static values = {
    reserveIds: Array,
    url: String,
  }

  declare tbodyTarget: HTMLTableSectionElement
  declare progressTarget: HTMLElement
  declare countTarget: HTMLElement
  declare totalTarget: HTMLElement
  declare itemTypeTarget: HTMLSelectElement
  declare reserveIdsValue: number[]
  declare urlValue: string

  private fetchGeneration = 0

  connect() {
    this.fetchAllReserves()
  }

  disconnect() {
    this.cancelPendingFetches()
  }

  refetch() {
    this.cancelPendingFetches()
    this.tbodyTarget.innerHTML = ""
    this.progressTarget.classList.remove("hidden")
    this.fetchAllReserves()
  }

  private cancelPendingFetches() {
    this.fetchGeneration++
  }

  async fetchAllReserves() {
    const generation = this.fetchGeneration
    const ids = this.reserveIdsValue
    const itemType = this.itemTypeTarget.value
    this.totalTarget.textContent = ids.length.toString()
    let loaded = 0

    for (const id of ids) {
      if (this.fetchGeneration !== generation) return

      try {
        let fetchUrl = `${this.urlValue}?zotero_id=${id}`
        if (itemType) {
          fetchUrl += `&item_type=${encodeURIComponent(itemType)}`
        }

        const response = await fetch(fetchUrl, {
          headers: { "Accept": "application/json" },
        })

        if (this.fetchGeneration !== generation) return

        if (response.ok) {
          const data = await response.json()
          if (this.fetchGeneration !== generation) return
          this.appendRow(data.name, data.pub_count)
        } else {
          this.appendErrorRow(id)
        }
      } catch {
        if (this.fetchGeneration !== generation) return
        this.appendErrorRow(id)
      }

      loaded++
      this.countTarget.textContent = loaded.toString()
    }

    if (this.fetchGeneration === generation) {
      this.progressTarget.classList.add("hidden")
    }
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
