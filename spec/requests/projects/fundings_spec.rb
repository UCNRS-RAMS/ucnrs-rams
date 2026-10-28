require "rails_helper"

RSpec.describe Projects::FundingsController, type: :request do
  describe "/projects/:id/fundings" do
    it "renders the fundings page when the user is authorized" do
      user = create(:user, :confirmed)
      sign_in(user)
      project = create(:project)
      membership = create(
        :project_team_membership,
        user: user,
        project: project,
        active: true,
        can_edit_project: true,
      )

      get "/projects/#{project.id}/fundings"

      doc = Capybara.string(response.body)
      expect(response).to be_ok
      expect(doc).to have_css("body.fundings-index")
    end

    it "redirects to the project summary page when the user is not authorized" do
      user = create(:user, :confirmed)
      sign_in(user)
      project = create(:project)
      membership = create(
        :project_team_membership,
        user: user,
        project: project,
        active: true,
        can_edit_project: false,
      )

      get "/projects/#{project.id}/fundings"

      expect(response).to redirect_to(project_url(project))
    end
  end

  describe "POST /projects/:id/fundings" do
    it "creates a funding for the project" do
      user = create(:user, :confirmed)
      sign_in(user)
      project = create(:project)
      create(
        :project_team_membership,
        user: user,
        project: project,
        active: true,
        can_edit_project: true,
      )

      post "/projects/#{project.id}/fundings", params: {
        funding: {
          title: "Give me money for birdwatching",
          principal_investigators: "Avery Visage",
          sponsor: "other",
          sponsor_other: "Audubon",
          start_date: "2000-12-31",
          end_date: "2021-01-01",
          award_amount: "1000000.00"
        }
      }

      funding = project.fundings.reload.first
      expect(response).to redirect_to(project_fundings_url(project))
      expect(funding.title).to eq "Give me money for birdwatching"
      expect(funding.sponsor_other).to eq "Audubon"
      expect(funding.award_amount).to eq 1_000_000
      expect(flash[:notice]).to eq I18n.t("projects.fundings.successfully_added_funding")
    end
  end

  describe "GET /fundings/:id/edit" do
    it "renders the funding edit modal" do
      user = create(:user, :confirmed)
      sign_in(user)
      funding = create(:funding)
      create(
        :project_team_membership,
        user: user,
        project: funding.project,
        active: true,
        can_edit_project: true,
      )

      get "/fundings/#{funding.id}/edit"

      doc = Capybara.string(response.body)
      expect(response).to be_ok
      expect(doc).to have_css("#edit-project-funding")
      expect(doc).to have_link(href: "/fundings/#{funding.id}")
    end
  end

  describe "PATCH /fundings/:id" do
    it "updates the funding" do
      user = create(:user, :confirmed)
      sign_in(user)
      funding = create(:funding)
      create(
        :project_team_membership,
        user: user,
        project: funding.project,
        active: true,
        can_edit_project: true,
      )

      patch "/fundings/#{funding.id}", params: {
        funding: {
          id: funding.id,
          title: "Give me money for birdwatching, please",
          principal_investigators: "Just me.",
          sponsor: "other",
          sponsor_other: "Audubon Society",
          start_date: "2000-12-31",
          end_date: "2021-01-01",
          award_amount: "1000000.23"
        }
      }

      funding.reload
      expect(response).to redirect_to(project_fundings_url(funding.project_id))
      expect(funding.title).to eq "Give me money for birdwatching, please"
      expect(funding.sponsor_other).to eq "Audubon Society"
      expect(funding.award_amount).to eq 1_000_000
    end
  end

  describe "DELETE /fundings/:id" do
    it "removes the funding from the project" do
      user = create(:user, :confirmed)
      sign_in(user)
      funding = create(:funding)
      create(
        :project_team_membership,
        user: user,
        project: funding.project,
        active: true,
        can_edit_project: true,
      )

      expect do
        delete "/fundings/#{funding.id}"
      end.to change(Funding, :count).by(-1)

      expect(response).to redirect_to(project_fundings_url(funding.project_id))
    end
  end
end
