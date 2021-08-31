require "rails_helper"

RSpec.describe Country, type: :model do
  describe "associations" do
    it { is_expected.to have_many(:institutions) }
    it { is_expected.to have_many(:user_address_countries).class_name("User").with_foreign_key(:address_country_id) }
    it { is_expected.to have_many(:user_billing_address_countries).class_name("User").with_foreign_key(:billing_address_country_id) }
  end
end
