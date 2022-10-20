require "rails_helper"

RSpec.describe Projects::UserNewPresenter do
  describe "delegations" do
    subject do
      Projects::UserNewPresenter.new(
        form: :fake_form,
        project: build_stubbed(:project),
      )
    end

    it { is_expected.to delegate_method(:institution_name).to(:form) }
  end

  describe "user_role_options" do
    it "puts the user role options (not incl. 'No Selection') into a useful array" do
      presenter = Projects::UserNewPresenter.new(
        form: :fake_form,
        project: build_stubbed(:project),
      )

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
        ["Reserve Staff", "reserve_staff"],
      ]
    end
  end

  describe "#project_role_options" do
    it "is a list of project role options" do
      presenter = Projects::UserNewPresenter.new(
        form: :fake_form,
        project: build_stubbed(:project),
      )

      expect(presenter.project_role_options).to eq [
        "PI - Principal Investigator",
        "Project Manager",
        "Team Member",
        "Billing",
      ]
    end
  end

  describe "#user_form_path" do
    it "returns the path for project users" do
      project = create(:project)
      presenter = Projects::UserNewPresenter.new(
        form: :fake_form,
        project: project,
      )

      expected_value = "/projects/#{project.id}/users"
      expect(presenter.user_form_path).to eq expected_value
    end
  end
end
