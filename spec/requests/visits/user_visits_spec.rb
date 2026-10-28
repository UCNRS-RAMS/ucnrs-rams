require "rails_helper"

RSpec.describe "Visit visitors page", type: :request do
  let(:user) { create(:user, :confirmed) }
  let(:visit) { create(:visit) }
  let(:institution) { create(:institution) }

  let(:turbo_stream_headers) { { "Accept" => "text/vnd.turbo-stream.html, text/html" } }

  before do
    create(:institution, id: 2368)
    sign_in(user)
  end

  describe "GET /visits/:visit_id/user_visits" do
    it "lists the visitors of the visit" do
      visitor = create(:user, :confirmed, first_name: "user1", last_name: "test1")
      user_visit = create(:user_visit, visit: visit, user: visitor, role: "Other")

      get visit_user_visits_path(visit)

      expect(response).to be_ok
      doc = Capybara.string(response.body)
      expect(doc).to have_css(".visits-form")
      expect(doc).to have_css("#visitors-summary")
      expect(doc).to have_css("#user_visit_#{user_visit.id}", text: "user1 test1")
      expect(doc).to have_css("#add-team-member")
      expect(doc).to have_css(".selected", text: "Add Team Member")
    end
  end

  describe "POST /visits/:visit_id/user_visits" do
    it "adds a group to the visitors list" do
      create(:user, :non_group_user)

      post visit_user_visits_path(visit, add_visitor_partial: "group"), params: {
        user_visit: {
          user_id: 1,
          visit_id: visit.id,
          count: 3,
          institution_id: institution.id,
          role: "faculty"
        }
      }, headers: turbo_stream_headers

      expect(response).to be_ok
      expect(visit.user_visits.last.count).to eq(3)
    end

    it "asks for guest details when no user was selected" do
      post visit_user_visits_path(visit, add_visitor_partial: "guest"), params: {
        user_visit: { visit_id: visit.id, guest_name: "hafiz" }
      }

      expect(response).to redirect_to(
        new_visit_user_visit_path(visit,
          add_visitor_partial: "guest",
          guest_name: "hafiz",
          show_add_guest_modal: true)
      )
    end

    it "creates the guest after the modal form is submitted" do
      create(:user, :non_group_user)

      post visit_user_visits_path(visit, add_visitor_partial: "guest"), params: {
        user_visit: {
          visit_id: visit.id,
          user_id: 1,
          guest_name: "hafiz",
          institution_id: institution.id,
          role: "faculty"
        }
      }, headers: turbo_stream_headers

      expect(response).to be_ok
      expect(visit.user_visits.last.guest_name).to eq("hafiz")
    end
  end

  describe "PATCH /user_visits/:id" do
    it "updates the visitor's arrival and departure dates" do
      user_visit = create(:user_visit, visit: visit)
      arrives_at = visit.starts_at.to_date + 1.day
      departs_at = visit.ends_at.to_date

      patch user_visit_path(user_visit), params: {
        user_visit: {
          id: user_visit.id,
          arrives_at: arrives_at,
          departs_at: departs_at,
          role: user_visit.role,
          institution_id: user_visit.institution_id
        }
      }

      expect(response).to redirect_to(visit_user_visits_path(visit))
      expect(user_visit.reload.arrives_at.to_date).to eq(arrives_at)
      expect(user_visit.departs_at.to_date).to eq(departs_at)
    end

    it "creates a new institution and assigns it to the visitor" do
      user_visit = create(:user_visit, visit: visit)

      patch user_visit_path(user_visit), params: {
        user_visit: {
          id: user_visit.id,
          arrives_at: user_visit.arrives_at,
          departs_at: user_visit.departs_at,
          role: user_visit.role,
          institution_id: user_visit.institution_id,
          institution: {
            name: "university-abc",
            city: "houstan",
            country_id: create(:country).id,
            institution_type: "california_state_university_system"
          }
        }
      }

      expect(response).to redirect_to(visit_user_visits_path(visit))
      expect(user_visit.reload.institution.name).to eq("university-abc")
    end

    it "rejects a duplicate institution name and keeps the old one" do
      create(:institution, name: "university-abc", city: "houstan")
      user_visit = create(:user_visit, visit: visit)
      original_institution = user_visit.institution

      patch user_visit_path(user_visit), params: {
        user_visit: {
          id: user_visit.id,
          arrives_at: user_visit.arrives_at,
          departs_at: user_visit.departs_at,
          role: user_visit.role,
          institution_id: user_visit.institution_id,
          institution: {
            name: "university-abc",
            city: "houstan",
            country_id: create(:country).id,
            institution_type: "california_state_university_system"
          }
        }
      }

      expect(response).to have_http_status(:unprocessable_content)
      expect(user_visit.reload.institution).to eq(original_institution)
    end
  end

  describe "GET /user_visits/:id/edit" do
    it "swaps in the new institution form when asked" do
      user_visit = create(:user_visit, visit: visit)

      get edit_user_visit_path(user_visit, display_institution_form: true),
        headers: turbo_stream_headers

      expect(response.media_type).to eq("text/vnd.turbo-stream.html")
      expect(response.body).to include("institution-fields")
    end
  end

  describe "DELETE /visits/:visit_id/user_visits/:id" do
    it "removes the visitor from the visitors list" do
      user_visit = create(:user_visit, visit: visit)

      delete visit_user_visit_path(visit, user_visit), headers: turbo_stream_headers

      expect(response).to be_ok
      expect(response.body).to include('target="user-visits-table"')
      expect(response.body).not_to include("user_visit_#{user_visit.id}")
      expect(UserVisit.find_by(id: user_visit.id)).to be_nil
    end
  end
end
