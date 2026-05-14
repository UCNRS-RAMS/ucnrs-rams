require "rails_helper"

RSpec.describe ReserveWaiver, type: :model do
  describe "associations" do
	it { is_expected.to belong_to(:reserve) }
	it { is_expected.to belong_to(:waiver) }
  end

  describe "validations" do
	subject(:reserve_waiver) { create(:reserve_waiver) }

	it { is_expected.to validate_uniqueness_of(:reserve_id).scoped_to(:waiver_id) }
  end
end

