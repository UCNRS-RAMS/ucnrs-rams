require "rails_helper"

RSpec.describe Manager::Reports::ReportPart8::ProjectPresenter do
  describe "delegations" do
    subject { Manager::Reports::ReportPart8::ProjectPresenter.new(:project) }
    it { is_expected.to delegate_method(:role).to(:owner).with_prefix(true) }
    it { is_expected.to delegate_method(:institution).to(:owner).with_prefix(true) }
    it { is_expected.to delegate_missing_methods_to(:project) }
  end

  describe "#owner" do
    it "presents the project user record wrapped in UserPresenter" do
      user = create(:user)
      project = create(:project, owner: user)
      presenter = Manager::Reports::ReportPart8::ProjectPresenter.new(project)

      owner = presenter.owner

      expect(owner.id).to eq user.id
      expect(owner).to be_a(UserPresenter)
    end
  end
end
