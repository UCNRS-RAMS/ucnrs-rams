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

  describe ".alphabetical_by_name" do
    it "returns all records ordered alphabetically by name" do
      wyoming = create(:state, name: "Wyoming")
      california = create(:state, name: "California")
      massachusetts = create(:state, name: "Massachusetts")

      expect(State.alphabetical_by_name).to contain_exactly(california, massachusetts, wyoming)
    end
  end

  describe ".in_country" do
    it "returns all state records associated with a given country" do
      united_states = create(:country)
      canada = create(:country)
      california = create(:state, country: united_states)
      massachusetts = create(:state, country: united_states)
      quebec = create(:state, country: canada)

      expect(State.in_country(united_states)).to match_array([california, massachusetts])
      expect(State.in_country(united_states)).not_to include(quebec)
    end
  end

  describe "#in_country?" do
    it "is true if the state is associated with the supplied country" do
      country = create(:country)
      state = create(:state, country: country)

      expect(state.in_country?(country)).to be true
    end

    it "is false if the state is not associated with the supplied country" do
      country = create(:country)
      other_country = create(:country)
      state = create(:state, country: country)

      expect(state.in_country?(other_country)).to be false
    end
  end
end
