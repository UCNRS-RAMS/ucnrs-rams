require "rails_helper"

RSpec.describe UserNewPresenter do
  describe "user_role_options" do
    it "puts the user role options (not incl. 'No Selection') into a useful array" do
      presenter = UserNewPresenter.new(form: :fake_form)

      expect(presenter.user_role_options).to eq [
        ["Faculty", "faculty"],
        ["Research Scientist/Post Doc", "research_scientist"],
        ["Research Assistant (non-student/faculty/postdoc)", "research_assistant"],
        ["Graduate Student", "graduate_student"],
        ["Undergraduate Student", "undergraduate_student"],
        ["K-12 Instructor", "k_12_instructor"],
        ["K-12 Student", "k_12_student"],
        ["Professional", "professional"],
        ["Other", "other"],
        ["Docent", "docent"],
        ["Volunteer", "volunteer"],
        ["Staff", "staff"],
      ]
    end
  end

  describe "#project_role_options" do
    it "is a list of project role options" do
      presenter = UserNewPresenter.new(form: :fake_form)

      expect(presenter.project_role_options).to eq [
        "PI - Principal Investigator",
        "Project Manager",
        "Team Member",
        "Billing",
      ]
    end
  end
end
