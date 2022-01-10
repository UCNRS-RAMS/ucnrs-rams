require "rails_helper"

RSpec.describe ProjectPermitAnswer, type: :model do
  describe "assocations" do
    it { is_expected.to belong_to(:permit) }
    it { is_expected.to belong_to(:project) }
  end

  describe "validations" do
    it { is_expected.to validate_booleanish_values(:answer) }
  end
end
