require "rails_helper"

RSpec.describe Projects::PermitsIndexPresenter do
  describe "delegations" do
    subject { Projects::PermitsIndexPresenter.new(current_step: 1, project: :dummy) }
    it { is_expected.to delegate_method(:svg).to(:steps_presenter) }
    it { is_expected.to delegate_method(:step_class).to(:steps_presenter) }
  end

  describe "#permits_by_authority" do
    it "groups permits according to the value of the authority field" do
      federal = create(:permit, authority: "Federal", involves_all: true)
      state = create(:permit, authority: "State", involves_all: true)
      local = create(:permit, authority: "Local", involves_all: true)
      institution = create(:permit, authority: "Institution", involves_all: true)
      state2 = create(:permit, authority: "State", involves_all: true, sort_order: 9)
      presenter = Projects::PermitsIndexPresenter.new(current_step: 3, project: build(:project))

      results = presenter.permits_by_authority

      expect(results.keys).to eq ["federal", "state", "local", "institution"]
      results.values.flatten.each do |value|
        expect(value).to be_a(Projects::PermitPresenter)
      end
      expect(results["federal"].map(&:id)).to eq [federal.id]
      expect(results["state"].map(&:id)).to eq [state.id, state2.id]
      expect(results["local"].map(&:id)).to eq [local.id]
      expect(results["institution"].map(&:id)).to eq [institution.id]
    end
  end
end
