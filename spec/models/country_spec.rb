require "rails_helper"

RSpec.describe Country, type: :model do
  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }
  end

  describe "associations" do
    it { is_expected.to have_many(:user_address_countries).class_name("User").with_foreign_key(:address_country_id) }
    it { is_expected.to have_many(:user_billing_address_countries).class_name("User").with_foreign_key(:billing_address_country_id) }
    it { is_expected.to have_many(:states) }
    it { is_expected.to have_many(:institutions) }
  end

  describe "#alphabetical_by_name" do
    it "returns all records ordered alphabetically by name" do
      united_states = create(:country, name: "United States")
      zimbabwe = create(:country, name: "Zimbabwe")
      afghanistan = create(:country, name: "Afghanistan")

      expect(Country.alphabetical_by_name).to contain_exactly(afghanistan, united_states, zimbabwe)
    end
  end
end
