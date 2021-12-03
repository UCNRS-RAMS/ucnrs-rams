require "rails_helper"

RSpec.describe Projects::TeamsEditPresenter do
  describe "delegations" do
    subject { Projects::TeamsEditPresenter.new(user: :dummy, current_step: 1) }
    it { is_expected.to delegate_method(:svg).to(:steps_presenter) }
    it { is_expected.to delegate_method(:step_class).to(:steps_presenter) }
  end
end
