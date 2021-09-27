require "rails_helper"

RSpec.describe Reserve, type: :model do
  describe "associations" do
    it { is_expected.to have_many(:amenities) }
  end
end
