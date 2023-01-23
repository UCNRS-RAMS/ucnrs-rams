require "rails_helper"

RSpec.describe Mail::ProjectCompletePresenter do
  describe "delegations" do
    subject { Mail::ProjectCompletePresenter.new(build(:project)) }
    it { is_expected.to delegate_missing_methods_to(:project) }
  end

  describe "#project_name" do
    it "return project 'title'" do
      project = create(:project, title: "Project")
      presenter = Mail::ProjectCompletePresenter.new(project)

      expect(presenter.project_name).to eq "Project"
    end
  end
end
