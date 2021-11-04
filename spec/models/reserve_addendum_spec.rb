require "rails_helper"

RSpec.describe ReserveAddendum, type: :model do
  describe "validations" do
    it { is_expected.to validate_presence_of(:subject) }
    it { is_expected.to validate_presence_of(:sort_order) }
  end

  describe "associations" do
    it { is_expected.to belong_to(:reserve) }
  end
end
