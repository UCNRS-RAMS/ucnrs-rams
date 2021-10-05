import { Application, Controller } from "stimulus"
import FollowupContentController from "./followup_content_controller"

global.fetch = jest.fn(() =>
  Promise.resolve({
    ok: true,
    text: () => Promise.resolve("<span>hello!</span>"),
  })
)

const allowFetchToResolve = (timeout = 1) =>
  new Promise((r) => setTimeout(r, timeout))

describe("FollowupContentController", () => {
  describe("#change from a select click", () => {
    beforeEach(() => {
      document.body.innerHTML = `
        <section
          data-controller="followup-content"
          data-followup-content-url-value="http://localhost/?thing=VALUE"
        >
          <select
            id="source"
            data-action="change->followup-content#change"
            name="source"
            value="Cool Button"
          >
            <option value="green">Green</option>
            <option value="red">Red</option>
            <option value="blue">Blue</option>
          </select>
          <div id="content" data-followup-content-target="destination"/>
        </section>`

      const application = Application.start()
      application.register("followup-content", FollowupContentController)
    })

    beforeEach(() => jest.clearAllMocks())

    it("HTTP requests the VALUE and puts the response in the destination", async () => {
      const source = document.getElementById("source")
      source.selectedIndex = 2

      source.dispatchEvent(new Event("change"))
      await allowFetchToResolve()

      expect(fetch).toHaveBeenCalledWith("http://localhost/?thing=blue")
      const hr = document.querySelector("#content hr")
      expect(hr).toBeNull()
      const span = document.querySelector("#content span")
      expect(span).not.toBeNull()
    })
  })

  describe("#change from input typing", () => {
    beforeEach(() => {
      document.body.innerHTML = `
        <section
          data-controller="followup-content"
          data-followup-content-length-value="2"
          data-followup-content-url-value="http://localhost/?thing=VALUE"
        >
          <input
            id="input"
            data-action="input->followup-content#change"
            name="input"
          />
          <div id="content" data-followup-content-target="destination">
            <hr/>
          </div>
        </section>`

      const application = Application.start()
      application.register("followup-content", FollowupContentController)
    })

    beforeEach(() => jest.clearAllMocks())

    it("makes an HTTP request with the value of the source", () => {
      const input = document.getElementById("input")
      input.value = "1234"
      const event = new Event("input")

      input.dispatchEvent(event)

      expect(fetch).toHaveBeenCalledWith("http://localhost/?thing=1234")
    })

    it("does not make a request unless enough has been typed", () => {
      const input = document.getElementById("input")
      input.value = "1"
      const event = new Event("input")

      input.dispatchEvent(event)

      expect(fetch).not.toHaveBeenCalled()
    })

    it("clears the destination if no request is made", () => {
      const input = document.getElementById("input")
      input.value = "a"
      const event = new Event("input")

      input.dispatchEvent(event)

      const hr = document.querySelector("#content hr")
      expect(hr).toBeNull()
    })
  })
})
