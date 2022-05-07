require "rails_helper"

RSpec.describe AnnualReport, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:reserve) }
  end
end
