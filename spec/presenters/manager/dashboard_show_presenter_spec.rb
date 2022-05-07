require "rails_helper"

RSpec.describe Manager::DashboardShowPresenter do
  describe "delegations" do
    subject { Manager::DashboardShowPresenter.new(reserve: build(:reserve)) }
    it { is_expected.to delegate_method(:id).to(:reserve).with_prefix(true) }
    it { is_expected.to delegate_method(:name).to(:reserve).with_prefix(true) }
  end

  describe "#reserve" do
    it "presents reserve informations correctly through the presenter" do
      reserve_one = create(:reserve, id: 1, name: "reserve 1")

      show_presenter = Manager::DashboardShowPresenter.new(reserve: reserve_one)

      expect(show_presenter.reserve_name).to eq "reserve 1"
    end
  end
end
