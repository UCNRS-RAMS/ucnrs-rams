require "rails_helper"

RSpec.describe Visits::UserVisitsController, type: :request do
  describe "GET /visits/:visit_id/user_visits/new" do
    it "renders the add visitor form with no institution selected when the user's institution has no type" do
      institution = build(:institution, id: 9001, institution_type: nil)
      institution.save!(validate: false)
      user = create(:user, :confirmed, institution: institution)
      project = create(:project)
      create(:project_team_membership, user: user, project: project, active: true)
      visit = create(:visit, project: project)
      sign_in(user)

      get "/visits/#{visit.id}/user_visits/new",
        params: { add_visitor_partial: "group" },
        headers: { "Accept" => "text/vnd.turbo-stream.html, text/html" }

      expect(response).to have_http_status(:ok)
      page = Capybara.string(response.body[%r{<template>(.*)</template>}m, 1])
      expect(page).to have_select("user_visit_institution_id", with_options: [ "- Select Institution -" ])
      expect(page).to have_no_css("#user_visit_institution_id option[selected]")
    end
  end
end
