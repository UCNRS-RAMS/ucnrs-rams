require "rails_helper"

RSpec.describe State, type: :model do
  describe "associations" do
    it { is_expected.to have_many(:institutions) }
    it { is_expected.to have_many(:user_address_states).class_name("User").with_foreign_key(:address_state_id) }
    it { is_expected.to have_many(:user_billing_address_states).class_name("User").with_foreign_key(:billing_address_state_id) }
  end
end
