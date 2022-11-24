require "rails_helper"

RSpec.describe InvoicePresenter do
  let(:project) { create(:project) }
  let(:reserve) { create(:reserve) }
  let(:visit) { create(:visit, reserve: reserve, project: project) }
  let(:invoice) { create(:invoice, visit: visit) }
  let(:user) { create(:user, :confirmed) }

  describe "delegations" do
    subject { InvoicePresenter.new(invoice: invoice) }
    it { is_expected.to delegate_method(:id).to(:invoice) }
    it { is_expected.to delegate_method(:status).to(:invoice) }
    it { is_expected.to delegate_method(:balance_due).to(:invoice) }
    it { is_expected.to delegate_method(:amenity_visits).to(:invoice) }
    it { is_expected.to delegate_method(:modify_number).to(:invoice) }
    it { is_expected.to delegate_method(:invoice_payments).to(:invoice) }
    it { is_expected.to delegate_method(:reserve_name).to(:visit) }
    it { is_expected.to delegate_method(:id).to(:visit).with_prefix(true) }
    it { is_expected.to delegate_method(:reserve_id).to(:visit) }
  end

  describe "#amenities_total" do
    it "return amenity_visits total of invoice" do
      amenity_visit = create(:amenity_visit, invoice_id: invoice.id, rate: 10)
      presenter = InvoicePresenter.new(invoice)
      output =  "$%0.2f" % [amenity_visit.subtotal]

      expect(presenter.amenities_total).to eq output
    end
  end

  describe "#amount" do
    it "return amenity_visits total of invoice" do
      invoice = create(:invoice, balance_due: 10)

      presenter = InvoicePresenter.new(invoice)
      output =  "$ %0.2f" % [invoice.balance_due]

      expect(presenter.amount).to eq output
    end
  end
end
