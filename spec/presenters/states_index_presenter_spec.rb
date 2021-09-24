require 'rails_helper'

RSpec.describe StatesIndexPresenter do
  describe "#states" do
    it "presents the relevant states in order" do
      country = create(:country)
      another_country = create(:country)
      state_one = create(:state, name: "One", country: country)
      state_two = create(:state, name: "Two", country: country)
      state_three = create(:state, name: "Three", country: country)
      another_state = create(:state, country: another_country)
      presenter = StatesIndexPresenter.new(country: country)

      states = presenter.states

      expect(states.length).to eq 3
      expect(states[0].name).to eq "One"
      expect(states[1].name).to eq "Three"
      expect(states[2].name).to eq "Two"
      expect(states.any? { |state| state.id == another_state.id }).to be_falsey
    end
  end
end
