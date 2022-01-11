require "rails_helper"

RSpec.describe ReserveShowPresenter do
  describe "delegations" do
    subject { ReserveShowPresenter.new(reserve: build(:reserve)) }
    it { is_expected.to delegate_method(:id).to(:reserve).with_prefix(true) }
    it { is_expected.to delegate_method(:name).to(:reserve).with_prefix(true) }
    it { is_expected.to delegate_method(:address_line_1).to(:reserve).with_prefix(true) }
    it { is_expected.to delegate_method(:address_line_2).to(:reserve).with_prefix(true) }
    it { is_expected.to delegate_method(:address_line_3).to(:reserve).with_prefix(true) }
    it { is_expected.to delegate_method(:address_postal_code).to(:reserve).with_prefix(true) }
    it { is_expected.to delegate_method(:state).to(:reserve).with_prefix(true) }
    it { is_expected.to delegate_method(:country).to(:reserve).with_prefix(true) }
    it { is_expected.to delegate_method(:avatar).to(:reserve).with_prefix(true) }
    it { is_expected.to delegate_method(:image_placeholder).to(:reserve).with_prefix(true) }
    it { is_expected.to delegate_method(:managing_campus).to(:reserve).with_prefix(true) }
    it { is_expected.to delegate_method(:reserve_alert_message).to(:reserve).with_prefix(true) }
    it { is_expected.to delegate_method(:directions).to(:reserve).with_prefix(true) }
    it { is_expected.to delegate_method(:description).to(:reserve).with_prefix(true) }
  end

  describe "#reserve" do
    it "presents reserve informations correctly through the presenter" do
      reserve_one = create(:reserve, id: 1, name: "reserve 1")

      show_presenter = ReserveShowPresenter.new(reserve: reserve_one)

      expect(show_presenter.reserve_id).to eq 1
      expect(show_presenter.reserve_name).to eq "reserve 1"
    end
  end

  describe "#personnel" do
    it "presents personnel informations correctly through the presenter" do
      reserve = create(:reserve)
      personnel_one = create(:reserve_personnel, id: 1, email: "t.kirk@enterprise.uss", reserve: reserve)
      personnel_two = create(:reserve_personnel, id: 2, email: "spock@enterprise.uss", reserve: reserve)
      personnel_three = create(:reserve_personnel, id: 3, email: "McCoy@enterprise.uss", reserve: reserve)

      show_presenter = ReserveShowPresenter.new(reserve: reserve)

      expect(show_presenter.reserve_personnel.first).to have_attributes(id: 1, email: "t.kirk@enterprise.uss")
      expect(show_presenter.reserve_personnel.second).to have_attributes(id: 2, email: "spock@enterprise.uss")
      expect(show_presenter.reserve_personnel.third).to have_attributes(id: 3, email: "McCoy@enterprise.uss")
    end
  end
end
