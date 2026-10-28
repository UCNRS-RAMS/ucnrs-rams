require "rails_helper"

RSpec.describe "Manager visit visitors", type: :request do
  let(:manager) { create(:user, :confirmed) }
  let(:reserve) { create(:reserve) }
  let(:visit) { create(:visit, reserve: reserve) }
  let(:institution) { create(:institution) }

  let(:turbo_stream_headers) { { "Accept" => "text/vnd.turbo-stream.html, text/html" } }

  before do
    create(:institution, id: 2368)
    create(:reserve_personnel, user: manager, reserve: reserve)
    sign_in(manager)
  end

  describe "switching the add visitor form" do
    it "renders the team member form on the visitors tab" do
      get manager_reserve_visit_user_visits_path(reserve, visit)

      doc = Capybara.string(response.body)
      expect(doc).to have_css(".add-visitor #add-team-member")
      expect(doc).to have_css(".selected", text: "Add Team Member")
      expect(doc).not_to have_css("#add-guest")
      expect(doc).not_to have_css("#add-group")
    end

    it "swaps to the guest form" do
      get new_visit_user_visit_path(visit, add_visitor_partial: "guest"),
        headers: turbo_stream_headers

      expect(response.media_type).to eq("text/vnd.turbo-stream.html")
      expect(response.body).to include('target="add-visitor"')
      expect(response.body).to include("add-guest")
      expect(response.body).not_to include("add-team-member")
    end

    it "swaps to the group form" do
      get new_visit_user_visit_path(visit, add_visitor_partial: "group"),
        headers: turbo_stream_headers

      expect(response.media_type).to eq("text/vnd.turbo-stream.html")
      expect(response.body).to include('target="add-visitor"')
      expect(response.body).to include("add-group")
      expect(response.body).not_to include("add-guest")
    end
  end

  describe "POST /visits/:visit_id/user_visits" do
    it "adds a project team member to the visitor list" do
      team_member = create(:user, :confirmed, institution: institution)
      create(:project_team_membership, user: team_member, project: visit.project)

      post visit_user_visits_path(visit, add_visitor_partial: "team_members"), params: {
        user_visit: {
          user_id: team_member.id,
          visit_id: visit.id,
          institution_id: institution.id,
          role: "faculty",
          count: 1
        }
      }, headers: turbo_stream_headers

      expect(response).to be_ok
      expect(response.body).to include('target="user-visits-table"')
      expect(visit.user_visits.find_by(user: team_member)).to be_present
    end

    it "adds a group to the visitor list" do
      create(:user, :non_group_user)

      post visit_user_visits_path(visit, add_visitor_partial: "group"), params: {
        user_visit: {
          user_id: 1,
          visit_id: visit.id,
          count: 4,
          institution_id: institution.id,
          role: "faculty"
        }
      }, headers: turbo_stream_headers

      expect(response).to be_ok
      user_visit = visit.user_visits.last
      expect(user_visit.count).to eq(4)
      expect(user_visit.guest_name).to be_blank
      expect(user_visit.institution).to eq(institution)
    end

    it "adds a selected user as a visitor" do
      visitor = create(:user, :confirmed, institution: institution)

      post visit_user_visits_path(visit, add_visitor_partial: "guest"), params: {
        user_visit: {
          visit_id: visit.id,
          user_id: visitor.id,
          guest_name: "John"
        }
      }, headers: turbo_stream_headers

      expect(response).to be_ok
      user_visit = visit.user_visits.find_by(user: visitor)
      expect(user_visit).to be_present
      expect(user_visit.guest_name).to be_blank
      expect(user_visit.institution).to eq(institution)
    end

    it "prompts for a new guest when no user was selected" do
      post visit_user_visits_path(visit, add_visitor_partial: "guest"), params: {
        user_visit: {
          visit_id: visit.id,
          guest_name: "hafiz"
        }
      }

      expect(response).to redirect_to(
        new_visit_user_visit_path(visit,
          add_visitor_partial: "guest",
          guest_name: "hafiz",
          show_add_guest_modal: true)
      )
      expect(visit.user_visits).to be_empty
    end

    it "creates the guest from the modal form" do
      create(:user, :non_group_user)

      post visit_user_visits_path(visit, add_visitor_partial: "guest"), params: {
        user_visit: {
          visit_id: visit.id,
          user_id: 1,
          guest_name: "hafiz",
          institution_id: institution.id,
          role: "faculty",
          count: 1
        }
      }, headers: turbo_stream_headers

      expect(response).to be_ok
      user_visit = visit.user_visits.last
      expect(user_visit.guest_name).to eq("hafiz")
      expect(user_visit.user_id).to eq(1)
    end
  end

  describe "GET /visits/:visit_id/user_visits/new" do
    it "renders the guest modal when the visit requests it" do
      get new_visit_user_visit_path(visit,
        add_visitor_partial: "guest",
        guest_name: "hafiz",
        show_add_guest_modal: true), headers: turbo_stream_headers

      expect(response.media_type).to eq("text/vnd.turbo-stream.html")
      expect(response.body).to include('target="modal-content"')
      expect(response.body).to include('value="hafiz"')
    end

    it "renders the create visitor modal for a project team member" do
      team_member = create(:user, :confirmed, institution: institution)

      get new_visit_user_visit_path(visit,
        user_id: team_member.id,
        institution_id: institution.id,
        role: "faculty"), headers: turbo_stream_headers

      expect(response.media_type).to eq("text/vnd.turbo-stream.html")
      expect(response.body).to include('target="modal-content"')
      expect(response.body).to include(team_member.full_name)
    end
  end

  describe "PATCH /manager/reserves/:reserve_id/user_visits/:id" do
    it "changes the arrival and departure dates of a visitor" do
      user_visit = create(:user_visit, visit: visit)
      arrives_at = visit.starts_at.to_date + 1.day
      departs_at = visit.ends_at.to_date

      patch manager_reserve_user_visit_path(reserve, user_visit), params: {
        user_visit: {
          id: user_visit.id,
          arrives_at: arrives_at,
          departs_at: departs_at,
          count: user_visit.count,
          role: user_visit.role,
          institution_id: user_visit.institution_id
        }
      }

      expect(response).to redirect_to(
        manager_reserve_visit_user_visits_path(reserve, visit)
      )
      expect(user_visit.reload.arrives_at.to_date).to eq(arrives_at)
      expect(user_visit.departs_at.to_date).to eq(departs_at)
    end

    it "renders the edit modal with the manual user days input" do
      user_visit = create(:user_visit, visit: visit, actual_days: 2)

      get edit_manager_reserve_user_visit_path(reserve, user_visit),
        headers: turbo_stream_headers

      expect(response.media_type).to eq("text/vnd.turbo-stream.html")
      expect(response.body).to include('target="modal-content"')
      expect(response.body).to include("user_visit_manual")
      expect(response.body).to include("user_visit_manual_user_days")
    end

    it "swaps in the new institution form when asked" do
      user_visit = create(:user_visit, visit: visit)

      get edit_manager_reserve_user_visit_path(reserve, user_visit,
        display_institution_form: true), headers: turbo_stream_headers

      expect(response.body).to include("institution-fields")
    end
  end

  describe "DELETE /manager/reserves/:reserve_id/visits/:visit_id/user_visits/:id" do
    it "removes the visitor from the visitors list" do
      user_visit = create(:user_visit, visit: visit)

      delete manager_reserve_visit_user_visit_path(reserve, visit, user_visit),
        headers: turbo_stream_headers

      expect(response).to be_ok
      expect(response.body).to include('target="user-visits-table"')
      expect(response.body).not_to include("user_visit_#{user_visit.id}")
      expect(UserVisit.find_by(id: user_visit.id)).to be_nil
    end
  end
end
