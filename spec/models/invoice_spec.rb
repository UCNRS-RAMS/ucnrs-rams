require "rails_helper"

RSpec.describe Invoice, type: :model do
  let(:user) { create(:user, :confirmed) }
  describe "associations" do
    it { is_expected.to have_many(:invoice_recipients) }
    it { is_expected.to have_many(:users).through(:invoice_recipients) }
    it { is_expected.to have_many(:invoice_payments) }
    it { is_expected.to have_many(:amenity_visits) }
    it { is_expected.to belong_to(:visit) }
  end

  describe ".recent_first" do
    it "returns records in reverse chronological order" do
      one = travel_to(1.week.ago) { create(:invoice) }
      two = travel_to(1.month.ago) { create(:invoice) }
      three = create(:invoice)

      results = Invoice.recent_first

      expect(results).to eq([three, one, two])
    end
  end

  describe ".by_reserve" do
    context "when not present? is passed in" do
      it "returns all visit records" do
        reserve = create(:reserve)
        invoice1 = create(:invoice, visit: create(:visit, reserve: reserve))
        invoice2 = create(:invoice, visit: create(:visit, reserve: reserve))
        invoice3 = create(:invoice, visit: create(:visit))

        results = Invoice.by_reserve(nil)

        expect(results).to eq [invoice1, invoice2, invoice3]
      end
    end

    context "when a reserve is given" do
      it "returns all visit records for that reserve" do
        reserve = create(:reserve)
        invoice1 = create(:invoice, visit: create(:visit, reserve: reserve))
        invoice2 = create(:invoice, visit: create(:visit, reserve: reserve))
        invoice3 = create(:invoice, visit: create(:visit))

        results = Invoice.by_reserve(reserve)

        expect(results).to eq [invoice1, invoice2]
      end
    end
  end

  describe ".for_status" do
    context "when not present? is passed in" do
      it "returns all visit records" do
        invoice1 = create(:invoice)
        invoice2 = create(:invoice, balance_due: 10)
        invoice3 = create(:invoice)

        results = Invoice.for_status(nil)

        expect(results).to eq [invoice1, invoice2, invoice3]
      end
    end

    context "when 'status' is passed in" do
      it "returns all invoice records with the given status" do
        invoice1 = create(:invoice)
        invoice2 = create(:invoice, balance_due: 10)
        invoice3 = create(:invoice)

        results = Invoice.for_status("paid")

        expect(results).to eq [invoice1, invoice3]
      end
    end
  end

  describe "#status" do
    it "returns 'due' if invoice payments_total is less then invoice amenity_visits_total" do
      invoice = create(:invoice, balance_due: 100)

      expect(invoice.status).to eq 'due'
    end

    it "returns 'paid' if invoice payments_total greater then or equal to invoice amenity_visits_total" do
      invoice = create(:invoice)

      expect(invoice.status).to eq 'paid'
    end
  end

  describe "#payments_amount_total" do
    it "returns invoice_payments amount total" do
      invoice = create(:invoice)
      create(:invoice_payment, invoice: invoice, user: user, amount: 5)
      create(:invoice_payment, invoice: invoice, user: user, amount: 10)

      output = 15 

      expect(invoice.payments_amount_total).to eq output
    end
  end

  describe "#invoice_total" do
    it "returns amenity_visits total" do
      invoice = create(:invoice)
      create(:amenity_visit, invoice_id: invoice.id, number_of_people: 10, manual_units_of_time: 10, rate: 10)
      create(:amenity_visit, invoice_id: invoice.id, number_of_people: 10, manual_units_of_time: 10, rate: 10)
      output = invoice.amenity_visits.sum(&:subtotal)

      expect(invoice.invoice_total).to eq output
    end
  end
end
