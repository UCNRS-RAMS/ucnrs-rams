require "rails_helper"

RSpec.describe Log, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:record) }
    it { is_expected.to belong_to(:record_about).optional(true) }
    it { is_expected.to belong_to(:user).optional(true) }
    it { is_expected.to belong_to(:reserve).optional(true) }
  end
end
