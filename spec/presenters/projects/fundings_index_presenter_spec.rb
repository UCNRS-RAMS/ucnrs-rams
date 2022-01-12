require "rails_helper"

RSpec.describe Projects::FundingsIndexPresenter do
  describe "delegations" do
    subject { Projects::FundingsIndexPresenter.new(current_step: 4, project: :dummy) }
    it { is_expected.to delegate_method(:svg).to(:steps_presenter) }
    it { is_expected.to delegate_method(:step_class).to(:steps_presenter) }
  end
end
