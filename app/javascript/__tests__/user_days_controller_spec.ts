import { Application, Controller } from "@hotwired/stimulus"
import { renderDOM, clearDOM } from "./support/dom"
import UserDaysController from "../controllers/user_days_controller"


describe("UserDaysController", () => {
  beforeAll(() => {
    const application = Application.start()
    application.register("user-days", UserDaysController)
  })

  afterEach(() => clearDOM())

  beforeEach(() => {
    renderDOM(`
    <div data-modal-target="dialog openOnLoad" data-controller="user-days">
      <form action="/manager/reserves/1/user_visits/39" accept-charset="UTF-8" method="post">
        <input type="hidden" name="_method" value="patch" autocomplete="off">
        <input type="hidden" name="authenticity_token" value="30G7_jH04ncvHuaPGRFSWqZ5uiq3O73fnB73FuCTdmDn8XluO3t0G7skRYOPTZMemH-s9OmuVfwQA_3HADhYgQ" autocomplete="off">
        <input autocomplete="off" type="hidden" value="39" name="user_visit[id]" id="user_visit_id">
        <p class="screenreader-text">
          <span id="modal-title">Change Date Range</span>
          <span id="modal-description">A modal pop-up form to edit details of a visitor.</span>
        </p>
        <section class="text">
          <h2>Change Date Range</h2>
          <div class="field">
            <label for="user_visit_role">Role</label>
            <select name="user_visit[role]" id="user_visit_role"><option value="faculty">Faculty</option>
              <option value="research_scientist">Research Scientist/Post Doc</option>
              <option selected="selected" value="research_assistant">Research Assistant (non-student/faculty/postdoc)</option>
              <option value="graduate_student">Graduate Student</option>
              <option value="undergraduate_student">Undergraduate Student</option>
              <option value="k_12_instructor">K-12 Instructor</option>
              <option value="k_12_student">K-12 Student</option>
              <option value="professional">Professional</option>
              <option value="other">Other</option>
              <option value="docent">Docent</option>
              <option value="volunteer">Volunteer</option>
              <option value="staff">Staff</option>
            </select>
          </div>
            <div class="field">
              <label for="user_visit_guest_name">Guest name</label>
              <input type="text" value="ahmad" name="user_visit[guest_name]" id="user_visit_guest_name">
              <input data-user-days-target="count" autocomplete="off" type="hidden" value="1" name="user_visit[count]" id="user_visit_count">
            </div>
          <div class="field autocomplete" role="combobox" data-controller="autocomplete" data-autocomplete-url-value="/institutions" aria-expanded="false" data-autocomplete-ready-value="true">
            <label for="user_visit_institution_name">Institution name</label>
            <input placeholder="Search by Name" value="Totally a Real University" data-autocomplete-target="input" type="text" name="user_visit[institution_name]" id="user_visit_institution_name" autocomplete="off" spellcheck="false">
            <input data-autocomplete-target="hidden" autocomplete="off" type="hidden" value="3" name="user_visit[institution_id]" id="user_visit_institution_id">
            <div class="autocomplete-results-container">
              <ul class="autocomplete-results" data-autocomplete-target="results" hidden=""></ul>
            </div>
            <div class="link">
              <a target="_blank" href="/institutions/new">Create New Institution</a>
            </div>
          </div>
          <table>
            <tbody><tr>
              <td colspan="2">
                <div class="date-range-select">
                  <div class="field">
                    <label for="user_visit_arrives_at">Arrives at</label>
                    <input data-user-days-target="arrivesAt" data-action="input->user-days#calculate" value="2022-09-27" type="date" name="user_visit[arrives_at]" id="user_visit_arrives_at">
                  </div>
                  <span class="separator"></span>
                  <div class="field">
                    <label for="user_visit_departs_at">Departs at</label>
                    <input data-user-days-target="departsAt" data-action="input->user-days#calculate" value="2022-09-28" type="date" name="user_visit[departs_at]" id="user_visit_departs_at">
                  </div>
                </div>
              </td>
            </tr>
          </tbody></table>
            <div class="d-flex">
              <div>
                <input id="user_visit_auto-calculate" data-action="click->user-days#disable" type="radio" value="auto_calculate" checked="checked" name="user_visit[userdays]">
                <label for="user_visit_auto-calculate">Use Arrival and Departure datetime:</label>
              </div>
              <div>
                <p data-user-days-target="output">2 days x 1 users = 2 userdays</p>
              </div>
            </div>
            <div class="d-flex">
              <div>
                <input id="user_visit_manual" data-action="click->user-days#enable" type="radio" value="auto_calculate" name="user_visit[userdays]">
                <label for="user_visit_manual">Manual enter number of userdays:</label>
              </div>
              <div>
                <input min="1" step="1" value="1" data-user-days-target="outputVal" class="m-right apply-padding" type="number" name="user_visit[actual_days]" id="user_visit_actual_days">
              </div>
            </div>
        </section>
        <section class="buttons">
          <div class="close">
            <a data-action="click->modal#close" href="#">Cancel</a>
          </div>
          <button class="active" type="submit">
            Save
          </button>
        </section>
      </form>
    </div>`)
  })

  describe("#calculate", () => {
    it("it set the default value for text", async () => {
      const departsAt = document.getElementById("user_visit_departs_at")
      const actualDays = document.getElementById("user_visit_actual_days")

      departsAt.value = '2022-09-29'
      departsAt.dispatchEvent(new Event("input"))
      expect(actualDays.value).toEqual("3")
    })
  })

  describe("#enable", () => {
    it("it remove readonly property of actual days input field", async () => {
      const radioBtnEnable = document.getElementById("user_visit_manual")
      const actualDays = document.getElementById("user_visit_actual_days")

      radioBtnEnable.click()
      expect(actualDays.getAttribute("disabled")).toEqual(null)
    })
  })

  describe("#disable", () => {
    it("it set the readonly property of actual days input field", async () => {
      const radioBtnDisable = document.getElementById("user_visit_auto-calculate")
      const actualDays = document.getElementById("user_visit_actual_days")

      radioBtnDisable.click()
      expect(actualDays.disabled).toEqual(true)
    })
  })

})
