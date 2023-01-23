require "rails_helper"

RSpec.describe Mail::User::ProjectCompletePresenter do
  describe "#email_subject" do
    it "presents sentence string for email subject" do
      user = create(:user, first_name: "john", last_name: "doe")
      start_date= Date.new(2022, 1, 1)
      end_date= Date.new(2022, 1, 2)
      project = create(:project, applicant: user, title: "Project", start_date: start_date, end_date: end_date)
      presenter = Mail::User::ProjectCompletePresenter.new(project)

      email_subject = presenter.email_subject

      expect(email_subject).to eq "New Project Project - Jan 1 - 2, 2022 - john doe".squish
    end
  end

  describe "#team_member_emails" do
    it "return array of team_member's emails" do
      project = create(:project)
      create(:project_team_membership, project: project, user: create(:user, email: "john1@example.com"))
      create(:project_team_membership, project: project, user: create(:user, email: "john2@example.com")) 
      create(:project_team_membership, project: project, user: create(:user, email: "john3@example.com")) 

      presenter = Mail::User::ProjectCompletePresenter.new(project)

      expect(presenter.team_member_emails).to match_array ["john1@example.com", "john2@example.com", "john3@example.com"]
    end
  end
end
