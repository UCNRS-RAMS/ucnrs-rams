require "rails_helper"

RSpec.describe Waiver, type: :model do
  describe "associations" do
    it { is_expected.to have_and_belong_to_many(:reserves) }
  end
end
