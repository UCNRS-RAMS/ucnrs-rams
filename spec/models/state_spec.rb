require "rails_helper"

RSpec.describe State, type: :model do
  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:country) }
  end

  describe "associations" do
    it { is_expected.to belong_to(:country) }
    it { is_expected.to have_many(:user_address_states).class_name("User").with_foreign_key(:address_state_id) }
    it { is_expected.to have_many(:user_billing_address_states).class_name("User").with_foreign_key(:billing_address_state_id) }
    it { is_expected.to have_many(:institutions) }
  end

  describe "#alphabetical_by_name" do
    it "returns all records ordered alphabetically by name" do
      wyoming = create(:state, name: "Wyoming")
      california = create(:state, name: "California")
      massachusetts = create(:state, name: "Massachusetts")

      expect(State.alphabetical_by_name).to contain_exactly(california, massachusetts, wyoming)
    end
  end
end
