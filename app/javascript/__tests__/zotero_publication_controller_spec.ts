import { Application } from "@hotwired/stimulus"
import { renderDOM, clearDOM } from "./support/dom"
import ZoteroPublicationController from "../controllers/zotero_publication_controller"

const waitForPromises = (timeout = 10) =>
  new Promise((r) => setTimeout(r, timeout))

const mockFetchResponse = (data: object, ok = true) =>
  Promise.resolve({
    ok,
    json: () => Promise.resolve(data),
  } as Response)

describe("ZoteroPublicationController", () => {
  let application: Application

  beforeAll(() => {
    application = Application.start()
    application.register("zotero-publication", ZoteroPublicationController)
  })

  beforeEach(() => {
    jest.clearAllMocks()
  })

  afterEach(() => {
    clearDOM()
  })

  const renderController = (reserveIds: number[] = [1, 2], url = "/pub_counts") => {
    // Stub fetch before rendering so connect() uses our mock
    global.fetch = jest.fn(() => mockFetchResponse({ name: "Reserve A", pub_count: "5" }))

    renderDOM(`
      <section
        data-controller="zotero-publication"
        data-zotero-publication-reserve-ids-value='${JSON.stringify(reserveIds)}'
        data-zotero-publication-url-value="${url}"
      >
        <select data-zotero-publication-target="itemType">
          <option value="">All</option>
          <option value="journalArticle">Journal Article</option>
        </select>
        <div data-zotero-publication-target="progress">
          <span data-zotero-publication-target="count">0</span>
          /
          <span data-zotero-publication-target="total">0</span>
        </div>
        <table>
          <tbody data-zotero-publication-target="tbody"></tbody>
        </table>
      </section>
    `)
  }

  describe("connect", () => {
    it("sets the total count from reserve IDs", async () => {
      renderController([10, 20, 30])
      await waitForPromises()

      const total = document.querySelector("[data-zotero-publication-target='total']")
      expect(total.textContent).toEqual("3")
    })

    it("fetches data for each reserve ID", async () => {
      renderController([10, 20])
      await waitForPromises()

      expect(global.fetch).toHaveBeenCalledTimes(2)
      expect((global.fetch as jest.Mock).mock.calls[0][0]).toContain("zotero_id=10")
      expect((global.fetch as jest.Mock).mock.calls[1][0]).toContain("zotero_id=20")
    })

    it("appends a row for each successful response", async () => {
      global.fetch = jest.fn()
        .mockResolvedValueOnce({ ok: true, json: () => Promise.resolve({ name: "Alpha Reserve", pub_count: "12" }) })
        .mockResolvedValueOnce({ ok: true, json: () => Promise.resolve({ name: "Beta Reserve", pub_count: "7" }) })

      renderDOM(`
        <section
          data-controller="zotero-publication"
          data-zotero-publication-reserve-ids-value='[1,2]'
          data-zotero-publication-url-value="/pub_counts"
        >
          <select data-zotero-publication-target="itemType"><option value="">All</option></select>
          <div data-zotero-publication-target="progress">
            <span data-zotero-publication-target="count">0</span>
            / <span data-zotero-publication-target="total">0</span>
          </div>
          <table><tbody data-zotero-publication-target="tbody"></tbody></table>
        </section>
      `)
      await waitForPromises()

      const rows = document.querySelectorAll("tbody tr")
      expect(rows.length).toEqual(2)
      expect(rows[0].textContent).toContain("Alpha Reserve")
      expect(rows[0].textContent).toContain("12")
      expect(rows[1].textContent).toContain("Beta Reserve")
      expect(rows[1].textContent).toContain("7")
    })

    it("updates the loaded count as each request completes", async () => {
      renderController([1])
      await waitForPromises()

      const count = document.querySelector("[data-zotero-publication-target='count']")
      expect(count.textContent).toEqual("1")
    })

    it("hides the progress indicator when all fetches complete", async () => {
      renderController([1])
      await waitForPromises()

      const progress = document.querySelector("[data-zotero-publication-target='progress']") as HTMLElement
      expect(progress.classList.contains("hidden")).toBe(true)
    })
  })

  describe("fetch URL construction", () => {
    it("includes the base URL and zotero_id parameter", async () => {
      renderController([42], "/my/endpoint")
      await waitForPromises()

      expect((global.fetch as jest.Mock).mock.calls[0][0]).toEqual("/my/endpoint?zotero_id=42")
    })

    it("appends item_type when a type is selected", async () => {
      global.fetch = jest.fn(() => mockFetchResponse({ name: "R", pub_count: "1" }))

      renderDOM(`
        <section
          data-controller="zotero-publication"
          data-zotero-publication-reserve-ids-value='[1]'
          data-zotero-publication-url-value="/pub_counts"
        >
          <select data-zotero-publication-target="itemType">
            <option value="">All</option>
            <option value="journalArticle" selected>Journal Article</option>
          </select>
          <div data-zotero-publication-target="progress">
            <span data-zotero-publication-target="count">0</span>
            / <span data-zotero-publication-target="total">0</span>
          </div>
          <table><tbody data-zotero-publication-target="tbody"></tbody></table>
        </section>
      `)
      await waitForPromises()

      expect((global.fetch as jest.Mock).mock.calls[0][0]).toContain("item_type=journalArticle")
    })
  })

  describe("error handling", () => {
    it("appends an error row when response is not ok", async () => {
      global.fetch = jest.fn(() => mockFetchResponse({}, false))

      renderDOM(`
        <section
          data-controller="zotero-publication"
          data-zotero-publication-reserve-ids-value='[99]'
          data-zotero-publication-url-value="/pub_counts"
        >
          <select data-zotero-publication-target="itemType"><option value="">All</option></select>
          <div data-zotero-publication-target="progress">
            <span data-zotero-publication-target="count">0</span>
            / <span data-zotero-publication-target="total">0</span>
          </div>
          <table><tbody data-zotero-publication-target="tbody"></tbody></table>
        </section>
      `)
      await waitForPromises()

      const row = document.querySelector("tbody tr")
      expect(row.textContent).toContain("Reserve #99")
      expect(row.textContent).toContain("—")
    })

    it("appends an error row when fetch throws a network error", async () => {
      global.fetch = jest.fn(() => Promise.reject(new Error("Network failure")))

      renderDOM(`
        <section
          data-controller="zotero-publication"
          data-zotero-publication-reserve-ids-value='[55]'
          data-zotero-publication-url-value="/pub_counts"
        >
          <select data-zotero-publication-target="itemType"><option value="">All</option></select>
          <div data-zotero-publication-target="progress">
            <span data-zotero-publication-target="count">0</span>
            / <span data-zotero-publication-target="total">0</span>
          </div>
          <table><tbody data-zotero-publication-target="tbody"></tbody></table>
        </section>
      `)
      await waitForPromises()

      const row = document.querySelector("tbody tr")
      expect(row.textContent).toContain("Reserve #55")
    })
  })

  describe("appendRow", () => {
    it("defaults pub_count to '0' when empty", async () => {
      global.fetch = jest.fn(() =>
        mockFetchResponse({ name: "Empty Reserve", pub_count: "" })
      )

      renderDOM(`
        <section
          data-controller="zotero-publication"
          data-zotero-publication-reserve-ids-value='[1]'
          data-zotero-publication-url-value="/pub_counts"
        >
          <select data-zotero-publication-target="itemType"><option value="">All</option></select>
          <div data-zotero-publication-target="progress">
            <span data-zotero-publication-target="count">0</span>
            / <span data-zotero-publication-target="total">0</span>
          </div>
          <table><tbody data-zotero-publication-target="tbody"></tbody></table>
        </section>
      `)
      await waitForPromises()

      const row = document.querySelector("tbody tr")
      expect(row.textContent).toContain("0")
    })

    it("adds fade-in class to new rows", async () => {
      renderController([1])
      await waitForPromises()

      const row = document.querySelector("tbody tr")
      expect(row.classList.contains("fade-in")).toBe(true)
    })
  })

  describe("escapeHtml", () => {
    it("escapes HTML entities in names", async () => {
      global.fetch = jest.fn(() =>
        mockFetchResponse({ name: "<script>alert('xss')</script>", pub_count: "1" })
      )

      renderDOM(`
        <section
          data-controller="zotero-publication"
          data-zotero-publication-reserve-ids-value='[1]'
          data-zotero-publication-url-value="/pub_counts"
        >
          <select data-zotero-publication-target="itemType"><option value="">All</option></select>
          <div data-zotero-publication-target="progress">
            <span data-zotero-publication-target="count">0</span>
            / <span data-zotero-publication-target="total">0</span>
          </div>
          <table><tbody data-zotero-publication-target="tbody"></tbody></table>
        </section>
      `)
      await waitForPromises()

      const row = document.querySelector("tbody tr")
      expect(row.innerHTML).not.toContain("<script>")
      expect(row.textContent).toContain("<script>alert('xss')</script>")
    })
  })

  describe("refetch", () => {
    it("clears existing rows and fetches again", async () => {
      renderController([1])
      await waitForPromises()

      expect(document.querySelectorAll("tbody tr").length).toEqual(1)

      // Reset fetch mock for the refetch call
      ;(global.fetch as jest.Mock).mockClear()
      global.fetch = jest.fn(() =>
        mockFetchResponse({ name: "Refreshed", pub_count: "99" })
      )

      // Trigger refetch via data-action
      const controller = application.getControllerForElementAndIdentifier(
        document.querySelector("[data-controller='zotero-publication']"),
        "zotero-publication"
      ) as any
      controller.refetch()
      await waitForPromises()

      const rows = document.querySelectorAll("tbody tr")
      expect(rows.length).toEqual(1)
      expect(rows[0].textContent).toContain("Refreshed")
    })

    it("shows the progress indicator during refetch", async () => {
      renderController([1])
      await waitForPromises()

      const progress = document.querySelector("[data-zotero-publication-target='progress']") as HTMLElement
      expect(progress.classList.contains("hidden")).toBe(true)

      const controller = application.getControllerForElementAndIdentifier(
        document.querySelector("[data-controller='zotero-publication']"),
        "zotero-publication"
      ) as any
      controller.refetch()

      // Progress should be visible during refetch
      expect(progress.classList.contains("hidden")).toBe(false)
      await waitForPromises()
    })
  })

  describe("with no reserve IDs", () => {
    it("hides progress immediately with zero fetches", async () => {
      renderController([])
      await waitForPromises()

      const progress = document.querySelector("[data-zotero-publication-target='progress']") as HTMLElement
      expect(progress.classList.contains("hidden")).toBe(true)
      expect(global.fetch).not.toHaveBeenCalled()
    })

    it("sets total to 0", async () => {
      renderController([])
      await waitForPromises()

      const total = document.querySelector("[data-zotero-publication-target='total']")
      expect(total.textContent).toEqual("0")
    })
  })
})
