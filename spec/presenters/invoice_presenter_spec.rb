require "rails_helper"

RSpec.describe InvoicePresenter do
  let(:project) { create(:project) }
  let(:reserve) { create(:reserve) }
  let(:visit) { create(:visit, reserve: reserve, project: project) }
  let(:invoice) { create(:invoice, visit: visit, invoiced_on: "31-10-1999") }
  let(:user) { create(:user, :confirmed) }

  describe "delegations" do
    subject { InvoicePresenter.new(invoice: invoice) }
    it { is_expected.to delegate_method(:id).to(:invoice) }
    it { is_expected.to delegate_method(:status).to(:invoice) }
    it { is_expected.to delegate_method(:balance_due).to(:invoice) }
    it { is_expected.to delegate_method(:amenity_visits).to(:invoice) }
    it { is_expected.to delegate_method(:modify_number).to(:invoice) }
    it { is_expected.to delegate_method(:invoice_payments).to(:invoice) }
    it { is_expected.to delegate_method(:reserve).to(:visit) }
    it { is_expected.to delegate_method(:reserve_name).to(:visit) }
    it { is_expected.to delegate_method(:id).to(:visit).with_prefix(true) }
    it { is_expected.to delegate_method(:reserve_id).to(:visit) }
    it { is_expected.to delegate_method(:reserve_name).to(:visit).allow_nil }
    it { is_expected.to delegate_method(:project_title).to(:visit).allow_nil }
    it { is_expected.to delegate_method(:user_full_name).to(:visit).allow_nil }
  end

  describe "#amenities_total" do
    it "return amenity_visits total of invoice" do
      amenity_visit = create(:amenity_visit, invoice_id: invoice.id, rate: 10)
      presenter = InvoicePresenter.new(invoice)
      output =  "$%0.2f" % [amenity_visit.subtotal]

      expect(presenter.amenities_total).to eq output
    end
  end

  describe "#invoice_id" do
    it "return invoice_id with version number" do
      presenter = InvoicePresenter.new(invoice)
      output = "#{invoice.id}-#{invoice.modify_number}"

      expect(presenter.invoice_id).to eq output
    end
  end

  describe "#amenity_visit_dates" do
    it "return date_range between earliest arrives and latest departs date of amenity_visits" do
      visit = create(:visit, starts_at: 1.week.ago, ends_at: 4.week.from_now)
      amenity_visit1 = create(:amenity_visit, invoice: invoice, visit: visit, arrives: 1.week.ago, departs: 2.week.from_now)
      amenity_visit2 = create(:amenity_visit, invoice: invoice, visit: visit, arrives: Time.current, departs: 3.week.from_now)
      presenter = InvoicePresenter.new(invoice)
      output = DateRangePresenter.value(start_date: amenity_visit1.arrives, end_date: amenity_visit2.departs)

      expect(presenter.amenity_visit_dates).to eq output
    end
  end

  describe "#manager_show_path" do
    it "return invoice show page path" do
      presenter = InvoicePresenter.new(invoice)
      output = "/manager/reserves/#{reserve.id}/visits/#{visit.id}/invoices/#{invoice.id}"

      expect(presenter.manager_show_path).to eq output
    end
  end

  describe "#invoiced_on" do
    it "return date when payment for invoice happen" do
      presenter = InvoicePresenter.new(invoice)
      output = "Oct 31, 1999"

      expect(presenter.invoiced_on).to eq output
    end
  end

  describe "#invoice_status" do
    it "return 'pending if balance_due is greater the zero'" do
      invoice = create(:invoice, visit: visit, balance_due: 10)
      presenter = InvoicePresenter.new(invoice)
      output = "pending"

      expect(presenter.invoice_status).to eq output
    end

    it "return 'paid if balance_due is greater the zero'" do
      invoice = create(:invoice, visit: visit, balance_due: 0)
      presenter = InvoicePresenter.new(invoice)
      output = "paid"

      expect(presenter.invoice_status).to eq output
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
