require "rails_helper"

RSpec.describe "Manager visit actions", type: :request do
  let(:manager) { create(:user, :confirmed) }
  let(:reserve) { create(:reserve) }
  let(:visit) { create(:visit, reserve: reserve) }

  before do
    create(:reserve_personnel, user: manager, reserve: reserve)
    sign_in(manager)
  end

  describe "PUT /manager/reserves/:reserve_id/visits/:visit_id/summary" do
    it "updates the visit status and its visitor statuses" do
      user_visit = create(:user_visit, visit: visit)
      amenity_visit = create(:amenity_visit, visit: visit)

      put manager_reserve_visit_summary_path(reserve, visit), params: {
        visit: {
          id: visit.id,
          status: "approved",
          email_notification_method: "silently_update"
        }
      }, headers: { "Accept" => "text/vnd.turbo-stream.html, text/html" }

      expect(response).to be_ok
      expect(visit.reload.status).to eq("approved")
      expect(user_visit.reload).to be_approved_status
      expect(amenity_visit.reload).to be_approved
      expect(response.body).to include('target="visit_summary_box"')
      expect(response.body).to include('target="flash"')
    end

    it "emails the selected recipients when composing an update email" do
      ActionMailer::Base.deliveries.clear

      put manager_reserve_visit_summary_path(reserve, visit), params: {
        visit: {
          id: visit.id,
          status: "approved",
          email_notification_method: "composed_email",
          approval_message: "Your visit was approved.",
          email_to_list: [ "composed@example.com" ]
        }
      }, headers: { "Accept" => "text/vnd.turbo-stream.html, text/html" }

      expect(response).to be_ok
      expect(ActionMailer::Base.deliveries.map(&:to)).to include([ "composed@example.com" ])
    end

    it "re-renders the form without changing the visit when the update fails" do
      invalid_visit = create(:visit, :without_validations, reserve: reserve,
        start_date: Date.current, end_date: Date.current - 1.day)

      put manager_reserve_visit_summary_path(reserve, invalid_visit), params: {
        visit: { id: invalid_visit.id, status: "approved" }
      }

      expect(response).to have_http_status(:unprocessable_content)
      expect(Capybara.string(response.body)).to have_css("turbo-frame#visit-summary-edit")
      expect(invalid_visit.reload.status).to eq("incomplete")
    end
  end

  describe "DELETE /manager/reserves/:reserve_id/visits/:id" do
    it "deletes the visit, its visitors and its invoices" do
      user_visit = create(:user_visit, visit: visit)
      invoice = create(:invoice, visit: visit)

      delete manager_reserve_visit_path(reserve, visit)

      expect(response).to redirect_to(manager_reserve_dashboard_path(format: :html))
      expect(flash[:notice]).to eq(I18n.translate("manager.visits.successfully_deleted_visit"))
      expect(Visit.find_by(id: visit.id)).to be_nil
      expect(UserVisit.find_by(id: user_visit.id)).to be_nil
      expect(Invoice.find_by(id: invoice.id)).to be_nil
    end

    it "redirects a reserve manager without administrator rights" do
      view_only_user = create(:user, :confirmed)
      create(:reserve_personnel, user: view_only_user, reserve: reserve, role: "View Only")
      sign_in(view_only_user)

      delete manager_reserve_visit_path(reserve, visit)

      expect(response).to redirect_to(root_url)
      expect(Visit.find_by(id: visit.id)).to be_present
    end
  end

  describe "POST /manager/reserves/:reserve_id/visits/:visit_id/reserve_info" do
    let(:reserve_question) do
      create(:reserve_question, reserve: reserve, location: "visit",
        question_type: "text", question: "Test question", answer_required: true)
    end

    it "saves the reserve answers and displays a success message" do
      post manager_reserve_visit_reserve_info_index_path(reserve, visit), params: {
        visit: {
          visit_reserve_answers: {
            reserve_question.id.to_s => { text_answer: "answer" }
          }
        }
      }

      expect(response).to be_ok
      expect(Capybara.string(response.body)).to have_css(".notice",
        text: I18n.translate("manager.update_message"))
      expect(visit.visit_reserve_answers.find_by(reserve_question: reserve_question).text_answer)
        .to eq("answer")
    end

    it "displays an error message when a required answer is missing" do
      post manager_reserve_visit_reserve_info_index_path(reserve, visit), params: {
        visit: {
          visit_reserve_answers: {
            reserve_question.id.to_s => { text_answer: "" }
          }
        }
      }

      expect(response).to be_ok
      expect(Capybara.string(response.body)).to have_css(".alert",
        text: I18n.translate("manager.error_message"))
      expect(visit.visit_reserve_answers.find_by(reserve_question: reserve_question)).to be_nil
    end
  end
end
