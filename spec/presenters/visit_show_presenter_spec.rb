require "rails_helper"

RSpec.describe VisitShowPresenter do
  describe "delegations" do
    subject { VisitShowPresenter.new(build(:visit)) }
    it { is_expected.to delegate_method(:id).to(:visit_reserve).with_prefix(true) }
    it { is_expected.to delegate_method(:name).to(:visit_reserve).with_prefix(true) }
    it { is_expected.to delegate_method(:address_line_1).to(:visit_reserve).with_prefix(true) }
    it { is_expected.to delegate_method(:address_line_2).to(:visit_reserve).with_prefix(true) }
    it { is_expected.to delegate_method(:address_line_3).to(:visit_reserve).with_prefix(true) }
    it { is_expected.to delegate_method(:address_city).to(:visit_reserve).with_prefix(true) }
    it { is_expected.to delegate_method(:address_postal_code).to(:visit_reserve).with_prefix(true) }
    it { is_expected.to delegate_method(:state).to(:visit_reserve).with_prefix(true) }
    it { is_expected.to delegate_method(:country).to(:visit_reserve).with_prefix(true) }
    it { is_expected.to delegate_method(:avatar).to(:visit_reserve).with_prefix(true) }
    it { is_expected.to delegate_method(:image_placeholder).to(:visit_reserve).with_prefix(true) }
    it { is_expected.to delegate_method(:managing_campus).to(:visit_reserve).with_prefix(true) }
    it { is_expected.to delegate_method(:reserve_alert_message).to(:visit_reserve).with_prefix(true) }
    it { is_expected.to delegate_missing_methods_to(:visit) }
  end

  describe "#sidebar_partial_name" do
    it "returns the sidebar partial path based on visit status" do
      visit = create(:visit, status: :approved)
      presenter = VisitShowPresenter.new(visit)

      expect(presenter.sidebar_partial_name).to eq "visits/sidebar_approved_show"
    end
  end

  describe "#visit_reserve_personnel" do
    it "creates a ReservePersonnelPresenter for each visit reserve personnel" do
      reserve = create(:reserve)
      reserve_personnel = create_list(:reserve_personnel, 3, reserve: reserve)
      visit = create(:visit, reserve: reserve)
      presenter = VisitShowPresenter.new(visit)

      results = presenter.visit_reserve_personnel

      expect(results.map(&:id)).to eq [
        reserve_personnel[0].id,
        reserve_personnel[1].id,
        reserve_personnel[2].id,
      ]
    end
  end

end
