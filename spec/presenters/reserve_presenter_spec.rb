require "rails_helper"

RSpec.describe ReservePresenter do
  describe "delegations" do
    subject { ReservePresenter.new(build(:reserve)) }
    it { is_expected.to delegate_missing_methods_to(:reserve) }
  end

  describe "address_line_3" do
    it "presents reserve address line 3" do
      state = create(:state, name: "state1")
      reserve = create(:reserve,
          address_city: "city1", address_postal_code: "12345", address_state: state
      )
      presenter = ReservePresenter.new(reserve)

      address_line_3 = presenter.address_line_3

      expect(address_line_3).to eq "city1, state1 12345"
    end
  end

  describe "state" do
    it "presents reserve state name" do
      state = create(:state, name: "state1")
      reserve = create(:reserve, address_state: state)
      presenter = ReservePresenter.new(reserve)

      state = presenter.state

      expect(state).to eq "state1"
    end
  end

  describe "country" do
    it "presents reserve country name" do
      country = create(:country, name: "country1")
      reserve = create(:reserve, address_country: country)
      presenter = ReservePresenter.new(reserve)

      country = presenter.country

      expect(country).to eq "country1"
    end
  end

  describe "#listing_photo_src" do
    context "when there is a listing photo uploaded" do
      it "is the medium version of the listing_photo" do
        reserve = create(:reserve, :with_listing_photo)
        presenter = ReservePresenter.new(reserve)

        expect(presenter.listing_photo_src).to match(/medium_test-image.jpeg/)
      end
    end

    context "when there is no listing photo uploaded" do
      it "is reserve's listing photo placeholder" do
        reserve = build(:reserve)
        presenter = ReservePresenter.new(reserve)

        expect(presenter.listing_photo_src).to eq("reserve_placeholder.jpg")
      end
    end
  end
end
