require "rails_helper"

RSpec.describe ReserveShowPresenter do
  describe "delegations" do
    subject { ReserveShowPresenter.new(reserve: build(:reserve), personnel: nil) }
    it { is_expected.to delegate_method(:id).to(:reserve).with_prefix(true) }
    it { is_expected.to delegate_method(:name).to(:reserve).with_prefix(true) }
    it { is_expected.to delegate_method(:address_line_1).to(:reserve).with_prefix(true) }
    it { is_expected.to delegate_method(:address_line_2).to(:reserve).with_prefix(true) }
    it { is_expected.to delegate_method(:address_city).to(:reserve).with_prefix(true) }
    it { is_expected.to delegate_method(:address_postal_code).to(:reserve).with_prefix(true) }
    it { is_expected.to delegate_method(:State).to(:reserve).with_prefix(true) }
    it { is_expected.to delegate_method(:Country).to(:reserve).with_prefix(true) }
    it { is_expected.to delegate_method(:has_avatar?).to(:reserve).with_prefix(true) }
    it { is_expected.to delegate_method(:reserve_avatar).to(:reserve).with_prefix(true) }
  end

  describe "#reserve" do
    it "presents reserve informations correctly through the presenter" do
      reserve_one = create(:reserve, id: 1, name: "reserve 1")

      show_presenter = ReserveShowPresenter.new(reserve: reserve_one, personnel: nil)

      expect(show_presenter.reserve_id).to eq 1
      expect(show_presenter.reserve_name).to eq "reserve 1"
    end
  end

  describe "#personnel" do
    it "presents personnel informations correctly through the presenter" do
      personnel_one = Personnel.new(1, "T Kirk")
      personnel_two = Personnel.new(2, "Spock")
      personnel_three = Personnel.new(3, "McCoy")

      show_presenter = ReserveShowPresenter.new(reserve: nil, personnel: [personnel_one, personnel_two, personnel_three])

      expect(show_presenter.personnel.first).to have_attributes(id: 1, name: "T Kirk")
      expect(show_presenter.personnel.second).to have_attributes(id: 2, name: "Spock")
      expect(show_presenter.personnel.third).to have_attributes(id: 3, name: "McCoy")
    end
  end
end
