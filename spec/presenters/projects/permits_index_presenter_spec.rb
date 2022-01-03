require "rails_helper"

RSpec.describe Projects::PermitsIndexPresenter do
  describe "delegations" do
    subject { Projects::PermitsIndexPresenter.new(current_step: 1, project: :dummy) }
    it { is_expected.to delegate_method(:svg).to(:steps_presenter) }
    it { is_expected.to delegate_method(:step_class).to(:steps_presenter) }
  end
end
