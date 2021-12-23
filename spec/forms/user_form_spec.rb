require "rails_helper"

RSpec.describe UserForm, type: :model do
  describe "delegations" do
    it { is_expected.to delegate_method(:id).to(:user) }
  end
end
