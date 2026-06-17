require "rails_helper"

RSpec.describe Projects::CompleteController, type: :request do
  describe "/projects/:id/complete" do
    it "redirects to the project summary page if the status was updated successfully" do
      user = create(:user, :confirmed)
      sign_in(user)
      project = create(:project, status: :incomplete)
      create(
        :project_team_membership,
        user: user,
        project: project,
        active: true,
        can_edit_project: true,
      )

      patch "/projects/#{project.id}/complete", params: { project_id: project.id }
      follow_redirect!

      doc = Capybara.string(response.body)
      expect(response).to be_ok
      expect(project.reload).to be_open
      expect(doc).to have_css("body.projects-show")
    end

    it "notifies the managers of each selected reserve on first submission" do
      user = create(:user, :confirmed)
      sign_in(user)
      project = create(:project, status: :incomplete)
      create(
        :project_team_membership,
        user: user,
        project: project,
        active: true,
        can_edit_project: true,
      )
      reserve_one = create(:reserve, email_address: "one@example.com")
      reserve_two = create(:reserve, email_address: "two@example.com")

      expect do
        patch "/projects/#{project.id}/complete", params: {
          project_id: project.id,
          project: { reserve_ids: [reserve_one.id, reserve_two.id] },
        }
      end.to have_enqueued_mail(UserMailer, :project_contact_manager).twice
    end

    it "does not notify reserve managers when the project was already submitted" do
      user = create(:user, :confirmed)
      sign_in(user)
      project = create(:project, status: :open)
      create(
        :project_team_membership,
        user: user,
        project: project,
        active: true,
        can_edit_project: true,
      )
      reserve = create(:reserve, email_address: "one@example.com")

      expect do
        patch "/projects/#{project.id}/complete", params: {
          project_id: project.id,
          project: { reserve_ids: [reserve.id] },
        }
      end.not_to have_enqueued_mail(UserMailer, :project_contact_manager)
    end

    it "renders the fundings page if updating was unsuccessful" do
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
      project_form_double = double(ProjectCompleteForm, save: false, project: project)
      allow(ProjectCompleteForm)
        .to receive(:new)
        .with(params: { id: project.id.to_s })
        .and_return(project_form_double)
      allow(project_form_double).to receive(:save).and_return(false)

      patch "/projects/#{project.id}/complete", params: { project_id: project.id }

      doc = Capybara.string(response.body)
      expect(response).to be_unprocessable
      expect(doc).to have_css("body.complete-update")
      expect(doc).to have_content("This project could not be saved as 'open'")
    end

    it "allows a project status update when the user is authorized" do
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

      patch "/projects/#{project.id}/complete", params: { project_id: project.id }
      follow_redirect!

      doc = Capybara.string(response.body)
      expect(response).to be_ok
      expect(doc).to have_css(".projects-show")
    end

    it "redirects to the project summary page when the user is not authorized" do
      user = create(:user, :confirmed)
      sign_in(user)
      project = create(:project)
      create(
        :project_team_membership,
        user: user,
        project: project,
        active: true,
        can_edit_project: false,
      )

      patch "/projects/#{project.id}/complete", params: { project_id: project.id }

      expect(response).to redirect_to(project_url(project))
    end
  end
end
