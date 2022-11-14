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
    it { is_expected.to delegate_method(:amenity_visits).to(:invoice) }
  end

  describe "#amenities_total" do
    it "return amenity_visits total of invoice" do
      amenity_visit = create(:amenity_visit, invoice_id: invoice.id, rate: 10)
      presenter = InvoicePresenter.new(invoice)
      output =  "$%0.2f" % [amenity_visit.subtotal]

      expect(presenter.amenities_total).to eq output
    end
  end
end
