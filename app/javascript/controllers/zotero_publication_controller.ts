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

  private abortController: AbortController | null = null

  connect() {
    this.fetchAllReserves()
  }

  refetch() {
    if (this.abortController) {
      this.abortController.abort()
    }
    this.tbodyTarget.innerHTML = ""
    this.progressTarget.classList.remove("hidden")
    this.fetchAllReserves()
  }

  async fetchAllReserves() {
    this.abortController = new AbortController()
    const signal = this.abortController.signal
    const ids = this.reserveIdsValue
    const itemType = this.itemTypeTarget.value
    this.totalTarget.textContent = ids.length.toString()
    let loaded = 0

    for (const id of ids) {
      if (signal.aborted) return

      try {
        let fetchUrl = `${this.urlValue}?zotero_id=${id}`
        if (itemType) {
          fetchUrl += `&item_type=${encodeURIComponent(itemType)}`
        }

        const response = await fetch(fetchUrl, {
          headers: { "Accept": "application/json" },
          signal,
        })

        if (signal.aborted) return

        if (response.ok) {
          const data = await response.json()
          if (signal.aborted) return
          this.appendRow(data.name, data.pub_count)
        } else {
          this.appendErrorRow(id)
        }
      } catch (error) {
        if (error instanceof DOMException && error.name === "AbortError") return
        if (signal.aborted) return
        this.appendErrorRow(id)
      }

      loaded++
      this.countTarget.textContent = loaded.toString()
    }

    if (!signal.aborted) {
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
