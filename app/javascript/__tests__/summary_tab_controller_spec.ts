import { Application, Controller } from "@hotwired/stimulus"
import { renderDOM, clearDOM } from "./support/dom"
import SummaryTabController from "../controllers/summary_tab_controller"

describe("SummaryTabController", () => {
  beforeAll(() => {
    const application = Application.start()
    application.register("summary-tab", SummaryTabController)
  })

  afterEach(() => clearDOM())

  beforeEach(() => {
    renderDOM(`
    <div class="summary" data-controller="summary-tab">
      <form action="/manager/reserves/1/visits/73/detail" accept-charset="UTF-8" method="post"><input type="hidden" name="_method" value="put" autocomplete="off"><input type="hidden" name="authenticity_token" value="7lcXUn0gib10JViSKK1T_EYytSN9-YTzAg1lArSTDLTF91HmjXQgs13G8ypnMU9U2dKTbhEJHXp2yfI4ftF5Zg" autocomplete="off">
        <div class="d-flex p-bottom">
          <div class="visit-status">
            <input id="approved" class="h-input" data-action="click->summary-tab#approvedStatusEmailMessage" type="radio" value="approved" checked="checked" name="visit[status]">
              <label for="approved" class="tab">
                <div class="d-flex">
                  <img height="24px" width="24px" alt="check icon" src="/assets/check-2485f0f0411571b2c01984388eb8307060a994266e87635de2dab77683a198b1.svg">
                  <span class="left-spacer"> Approve </span>
                </div>
              </label>

            <input id="in_review" class="h-input" data-action="click->summary-tab#clearField" type="radio" value="in_review" name="visit[status]">
            <label for="in_review" class="tab">
              <div class="d-flex">
                <img height="24px" width="24px" alt="clock iocn" src="/assets/clock-e124f2907f7ccc91c7cc84e65595d2178f68a37f07c4137a0f520a89c67e62e0.svg">
                <span class="left-spacer"> Pending Approval </span>
              </div>
            </label>
            
            <input id="cancelled" class="h-input" data-action="click->summary-tab#clearField" type="radio" value="cancelled" name="visit[status]">
            <label for="cancelled" class="tab">
              <div class="d-flex">
                <img height="24px" width="24px" alt="x-circle icon" src="/assets/x-circle-71e17b2632d72cec8bc4948ef7648e84c12ccf91a59c99642eed8b743ff741e4.svg">
                <span class="left-spacer"> Cancelled by Applicant </span>
              </div>
            </label>
            
            <input id="denied" class="h-input" data-action="click->summary-tab#clearField" type="radio" value="denied" name="visit[status]">
            <label for="denied" class="tab">
              <div class="d-flex">
                <img height="24px" width="24px" alt="x-icon" src="/assets/x-5cc154f4856d09f5560b47fa7ddeab45fa517bf2bf0d830fe112d8d3ed1115ad.svg">
                <span class="left-spacer"> Deny </span>
              </div>
            </label>
          </div>
          <div class="visit-status">
            <input id="incomplete" class="h-input" data-action="click->summary-tab#clearField" type="radio" value="incomplete" name="visit[status]">
            <label for="incomplete" class="tab">
              <div class="d-flex">
                <img height="24px" width="24px" alt="x-icon" src="/assets/minus-circle-4ba8408844bbf9fa1d20647982322f00c724f98df50ba58a44e5b8d972580a7e.svg">
                <span class="left-spacer"> Incomplete </span>
              </div>
            </label>
          </div>
        </div>
        <h2 class="p-bottom">Notification Email</h2>
        <div>
          <div class="d-flex">
            <div class="field">
              <label for="email-notification-method" class="label">Email Notification Method</label>
              <select class="email-notification-method" data-summary-tab-target="selectField" data-action="change->summary-tab#toggleEmailDiv" name="visit[email-notification-method]" id="visit_email-notification-method"><option value="composed_email">Send applicants a composed email</option>
                <option id="toBeSelect" value="silently_update">Silently update status</option>
              </select>
            </div>
            <div>
              <input name="visit[remove_visit_from_annual_report]" type="hidden" value="0" autocomplete="off"><input type="checkbox" value="1" name="visit[remove_visit_from_annual_report]" id="visit_remove_visit_from_annual_report">
              <label for="remove_visit_from_annual_report">Remove Visit From Anuual Report</label>
            </div>
          </div>
          <div class="email" data-summary-tab-target="emailDiv" id="toggleBLock" style="display: block;">
            <div class="field">
              <label for="email-message" class="label">Email Message</label>
              <textarea rows="15" data-summary-tab-target="textArea" class="email-message" name="visit[approval_message]" id="visit_approval_message"> ************************************* 
                      Your Approval Was submitted     
                ************************************* 
                Lorem ipsum dolor, sit amet consectetur adipisicing elit. Incidunt nesciunt quaerat consequatur recusandae dolores vero mollitia provident accusantium esse quae. Repudiandae labore, repellat quos eligendi laudantium enim incidunt adipisci! Id.
                  Adipisci porro modi repudiandae, possimus suscipit dignissimos dolores veniam nesciunt quam repellendus autem fugiat asperiores nisi magni ab explicabo. Minima id fugit sapiente harum minus repellendus velit quisquam non provident?
                  Delectus, accusantium unde sunt tenetur harum reprehenderit? Laboriosam neque itaque omnis maiores exercitationem suscipit numquam dolorum, hic inventore voluptas adipisci minima alias odit rem ipsam! Cupiditate delectus rerum perspiciatis officiis.
                  Ipsum natus recusandae dolore praesentium tenetur, porro id? Obcaecati amet delectus voluptate repellat iusto illum aperiam nobis suscipit consequuntur? Nostrum quae culpa voluptas maiores aliquid beatae tempore architecto totam et.
                  Doloremque cupiditate, nulla amet reiciendis rem tempore veritatis error labore sed, magni provident quisquam voluptatem. Laudantium expedita incidunt, natus, magnam, eos est itaque ratione rerum omnis autem veniam aliquam reiciendis.
                  Fugit porro, ipsum, quaerat corrupti, blanditiis magni obcaecati accusantium beatae sequi dolore reprehenderit fuga aut explicabo nobis quo. Quae ad corporis a. Facilis numquam maiores, iste minus eligendi saepe! Obcaecati.
                  Quis corporis asperiores culpa id ad fugit alias ex nemo</textarea>
                      <input type="hidden" name="message" id="message" value=" ************************************* 
                      Your Approval Was submitted     
                ************************************* 
                Lorem ipsum dolor, sit amet consectetur adipisicing elit. Incidunt nesciunt quaerat consequatur recusandae dolores vero mollitia provident accusantium esse quae. Repudiandae labore, repellat quos eligendi laudantium enim incidunt adipisci! Id.
                  Adipisci porro modi repudiandae, possimus suscipit dignissimos dolores veniam nesciunt quam repellendus autem fugiat asperiores nisi magni ab explicabo. Minima id fugit sapiente harum minus repellendus velit quisquam non provident?
                  Delectus, accusantium unde sunt tenetur harum reprehenderit? Laboriosam neque itaque omnis maiores exercitationem suscipit numquam dolorum, hic inventore voluptas adipisci minima alias odit rem ipsam! Cupiditate delectus rerum perspiciatis officiis.
                  Ipsum natus recusandae dolore praesentium tenetur, porro id? Obcaecati amet delectus voluptate repellat iusto illum aperiam nobis suscipit consequuntur? Nostrum quae culpa voluptas maiores aliquid beatae tempore architecto totam et.
                  Doloremque cupiditate, nulla amet reiciendis rem tempore veritatis error labore sed, magni provident quisquam voluptatem. Laudantium expedita incidunt, natus, magnam, eos est itaque ratione rerum omnis autem veniam aliquam reiciendis.
                  Fugit porro, ipsum, quaerat corrupti, blanditiis magni obcaecati accusantium beatae sequi dolore reprehenderit fuga aut explicabo nobis quo. Quae ad corporis a. Facilis numquam maiores, iste minus eligendi saepe! Obcaecati.
                  Quis corporis asperiores culpa id ad fugit alias ex nemo" data-summary-tab-target="approvalMessage" autocomplete="off">
            </div>
            <div class="p-bottom">
              <span><a data-action="click->summary-tab#clearField" id="clear_btn" data-remote="true" href="#">Clear message field</a></span>
              <span class="label left-spacer">This message is displayed in the visit page in the summary page in the public interface</span>
            </div>
            <h3>Email Reciepents</h3>
              <div class="team-member d-flex">
                <div> <span><input name="visit[recipient_email]" type="hidden" value="0" autocomplete="off"><input type="checkbox" value="1" checked="checked" name="visit[recipient_email]" id="visit_recipient_email"></span><b class="left-spacer">Mister Moustache</b> </div>
                <div>Totally a Real University</div>
                <div>PI - Principal Investigator</div>
              </div>
              <div class="team-member d-flex">
                <div> <span><input name="visit[recipient_email]" type="hidden" value="0" autocomplete="off"><input type="checkbox" value="1" checked="checked" name="visit[recipient_email]" id="visit_recipient_email"></span><b class="left-spacer">new  member</b> </div>
                <div>Totally a Real University</div>
                <div>PI - Principal Investigator</div>
              </div>
          </div>
          <div class="check-box" data-summary-tab-target="checkBoxDiv" style="display: none;">
            <div>
              <input name="visit[email_applicant_and_staff]" type="hidden" value="0" autocomplete="off"><input type="checkbox" value="1" name="visit[email_applicant_and_staff]" id="visit_email_applicant_and_staff">
              <label for="email_applicant_and_staff">Email Applicant and Staff</label>
            </div>
            <div>
              <input name="visit[email_staff_only]" type="hidden" value="0" autocomplete="off"><input type="checkbox" value="1" name="visit[email_staff_only]" id="visit_email_staff_only">
              <label for="email_staff_only">Email Staff Only</label>
            </div>
          </div>
        </div>
        <div>
          <input name="visit[cc_reciepents]" type="hidden" value="0" autocomplete="off"><input type="checkbox" value="1" checked="checked" name="visit[cc_reciepents]" id="visit_cc_reciepents">
          <label for="cc_reciepents">CC Reserve Personal(Staff signed up to be notified of status changes)</label>
        </div>
        <div class="d-flex-end">
          <input type="submit" name="commit" value="Update Status">
        </div>
      </form>  
    </div>`)
  })

  describe("#clearField", () => {
    it("clear the text area content", async () => {
      const textArea = document.getElementById("visit_approval_message")
      const clearBtn = document.getElementById("clear_btn")

      clearBtn.click()

      expect(textArea.value).toEqual("")
    })
  })
  
  describe("#approvedStatusEmailMessage", () => {
    it("it set the default value for text", async () => {
      const textArea = document.getElementById("visit_approval_message")
      const clearBtn = document.getElementById("clear_btn")
      const approvedStatusBtn = document.getElementById("approved")

      clearBtn.click()
      approvedStatusBtn.click()

      expect(textArea.value).not.toEqual("")      
    })
  })

  describe("#toggleEmailDiv", () => {
    it("it toggle the text area through drop down", async () => {
      const emailDropDown = document.getElementById("visit_email-notification-method")
      const toggleBLock = document.getElementById("toggleBLock")
      
      emailDropDown.selectedIndex = 1
      emailDropDown.dispatchEvent(new Event("change"))

      expect(toggleBLock.style.display).toEqual("none")
    })
  })
})
