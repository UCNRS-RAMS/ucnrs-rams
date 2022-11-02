require "rails_helper"

RSpec.describe Manager::ReserveInfo::ReserveFormPresenter do
  describe "delegations" do
    subject { Manager::ReserveInfo::ReserveFormPresenter.new(form: ReserveForm.new()) }
    it { is_expected.to delegate_method(:reserve).to(:form).with_prefix(true) }
  end

  describe "#reserve_name" do
    it "returns the name of the form reserve name" do
      reserve = create(:reserve, name: "reserve 1")
      form = ReserveForm.new(reserve: reserve)
      presenter = Manager::ReserveInfo::ReserveFormPresenter.new(form)

      expect(presenter.reserve_name).to eq reserve.name
    end
  end

  describe "#managing_campus_name" do
    it "returns the name of the form reserve managing campus" do
      managing_campus = create(:institution, name: "Study of Mice Institute")
      reserve = create(:reserve, managing_campus: managing_campus)
      form = ReserveForm.new(reserve: reserve)
      presenter = Manager::ReserveInfo::ReserveFormPresenter.new(form)

      expect(presenter.managing_campus_name).to eq managing_campus.name
    end
  end

  describe "#address_state_options" do
    context "when form reserve has an address_country_id" do
      it "returns an array of states alphabetically from the country" do
        country = create(:country)
        state1 = create(:state, country: country, name: "state b")
        state2 = create(:state, country: country, name: "state a")
        reserve = create(:reserve)
        form = ReserveForm.new(reserve: reserve, params: { address_country_id: country.id })
        presenter = Manager::ReserveInfo::ReserveFormPresenter.new(form)

        expect(presenter.address_state_options).to eq [state2, state1]
      end
    end

    context "when form reserve does not have an address_country_id" do
      it "returns an empty array" do
        reserve = create(:reserve)
        form = ReserveForm.new(reserve: reserve, params: { address_country_id: nil })
        presenter = Manager::ReserveInfo::ReserveFormPresenter.new(form)

        expect(presenter.address_state_options).to eq []
      end
    end
  end

  describe "#billing_address_state_options" do
    context "when form reserve has an billing_address_country_id" do
      it "returns an array of states alphabetically from the country" do
        country = create(:country)
        state1 = create(:state, country: country, name: "state b")
        state2 = create(:state, country: country, name: "state a")
        reserve = create(:reserve)
        form = ReserveForm.new(reserve: reserve, params: { billing_address_country_id: country.id })
        presenter = Manager::ReserveInfo::ReserveFormPresenter.new(form)

        expect(presenter.billing_address_state_options).to eq [state2, state1]
      end
    end

    context "when form reserve does not have an billing_address_country_id" do
      it "returns an empty array" do
        reserve = create(:reserve)
        form = ReserveForm.new(reserve: reserve, params: { billing_address_country_id: nil })
        presenter = Manager::ReserveInfo::ReserveFormPresenter.new(form)

        expect(presenter.billing_address_state_options).to eq []
      end
    end
  end


  describe "#hero_photo" do
    it "presents placeholder image if no large_hero_photo is attached" do
      reserve = build(:reserve)
      form = ReserveForm.new(reserve: reserve)
      presenter = Manager::ReserveInfo::ReserveFormPresenter.new(form)

      expect(presenter.hero_photo).to match(/\/assets\/reserve_placeholder/)
    end

    it "presents the correct avatar path if large_hero_photo is attached" do
      reserve = create(:reserve, :with_hero_photo)
      form = ReserveForm.new(reserve: reserve)
      presenter = Manager::ReserveInfo::ReserveFormPresenter.new(form)

      expect(presenter.hero_photo).to match(/\/tmp\/ucnrs-test\/reserve_id_#{reserve.id}\/test-image.jpeg/)
    end
  end

  describe "#listing_photo" do
    it "presents placeholder image if no listing_photo is attached" do
      reserve = create(:reserve)
      form = ReserveForm.new(reserve: reserve)
      presenter = Manager::ReserveInfo::ReserveFormPresenter.new(form)

      expect(presenter.listing_photo).to match(/\/assets\/reserve_placeholder/)
    end

    it "presents the correct avatar path if listing_photo is attached" do
      reserve = create(:reserve, :with_listing_photo)
      form = ReserveForm.new(reserve: reserve)
      presenter = Manager::ReserveInfo::ReserveFormPresenter.new(form)

      expect(presenter.listing_photo).to match(/\/tmp\/ucnrs-test\/reserve_id_#{reserve.id}\/test-image.jpeg/)
    end
  end
end
