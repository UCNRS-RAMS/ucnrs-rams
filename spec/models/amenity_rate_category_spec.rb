require "rails_helper"

RSpec.describe AmenityRateCategory, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:reserve) }
  end
end
