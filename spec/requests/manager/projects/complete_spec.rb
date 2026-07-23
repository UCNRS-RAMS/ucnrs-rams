require "rails_helper"

RSpec.describe Manager::Projects::CompleteController, type: :request do
  describe "PATCH /manager/reserves/:reserve_id/projects/:project_id/complete" do
    it "notifies the managers of each selected reserve on first submission" do
      user = create(:user, :confirmed)
      reserve = create(:reserve)
      project = create(:project, status: :incomplete, reserve: reserve)
      create(:reserve_personnel, user: user, reserve: reserve)
      create(
        :project_team_membership,
        user: user,
        project: project,
        active: true,
        can_edit_project: true,
      )
      sign_in(user)

      reserve_one = create(:reserve, email_address: "one@example.com")
      reserve_two = create(:reserve, email_address: "two@example.com")

      expect do
        patch "/manager/reserves/#{reserve.id}/projects/#{project.id}/complete", params: {
          project: { reserve_ids: [reserve_one.id, reserve_two.id] },
        }
      end.to have_enqueued_mail(UserMailer, :project_contact_manager).twice

      expect(project.reload).to be_open
    end

    it "does not notify reserve managers when the project was already submitted" do
      user = create(:user, :confirmed)
      reserve = create(:reserve)
      project = create(:project, status: :open, reserve: reserve)
      create(:reserve_personnel, user: user, reserve: reserve)
      sign_in(user)

      selected_reserve = create(:reserve, email_address: "one@example.com")

      expect do
        patch "/manager/reserves/#{reserve.id}/projects/#{project.id}/complete", params: {
          project: { reserve_ids: [selected_reserve.id] },
        }
      end.not_to have_enqueued_mail(UserMailer, :project_contact_manager)
    end
  end
end
