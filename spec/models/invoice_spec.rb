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

  describe ".searching_term" do
    context "when search_filter contain only numbers" do
      it "search invoice id" do
        invoice = create(:invoice)

        results = Invoice.searching_term(invoice.id.to_s)

        expect(results).to eq [invoice]
      end
    end

    context "when search_filter contain not only numbers" do
      let(:institution) { create(:institution, name: "No way home") }
      let(:user) { create(:user, last_name: "Vil", first_name: "Cruella", email: "ceo@house.of.vil", institution: institution) }
      let(:visit) { create(:visit, user: user, project: create(:project, title: "Observing kangaroo mouse.")) }
      let!(:invoice) do
        create :invoice,
        notes: "This invoice is already in the inventory",
        visit: visit
      end

      it "search invoice notes" do
        results = Invoice.searching_term("already")

        expect(results).to eq [invoice]
      end

      it "search invoice project title" do
        results = Invoice.searching_term("Observing kangaroo mouse.")

        expect(results).to eq [invoice]
      end

      it "search invoice user's last name" do
        results = Invoice.searching_term("Vil")

        expect(results).to eq [invoice]
      end

      it "search invoice user email" do
        results = Invoice.searching_term("ceo@house.of.vil")

        expect(results).to eq [invoice]
      end

      it "search invoice user's institution name" do
        results = Invoice.searching_term("No way home")

        expect(results).to eq [invoice]
      end
    end
  end

  describe ".sort_using" do
    it "calls the submitted recent first when supplied sort_option is 'created_recent_first'" do
      expect(Invoice).to receive(:sort_using).with("created_recent_first").and_return(Invoice.order(:invoiced_on))

      Invoice.sort_using "created_recent_first"
    end

    it "calls the sort by amount when supplied sort_option is 'sort_by_amount'" do
      expect(Invoice).to receive(:sort_using).with("sort_by_amount").and_return(Invoice.sort_by_amount)

      Invoice.sort_using "sort_by_amount"
    end

    it "calls the sort by balance_due when supplied sort_option is 'sort_by_balance_due'" do
      expect(Invoice).to receive(:sort_using).with("sort_by_balance_due").and_return(Invoice.order(:balance_due))

      Invoice.sort_using "sort_by_balance_due"
    end

    it "calls the sort by invoice id when supplied sort_option is 'sort_by_invoice_number'" do
      expect(Invoice).to receive(:sort_using).with("sort_by_invoice_number").and_return(Invoice.order(:id))

      Invoice.sort_using "sort_by_invoice_number"
    end

    it "returns all when supplied sort_option is not present" do
      expect(Invoice).to receive(:sort_using).and_return(Invoice.all)

      Invoice.sort_using
    end
  end

  describe ".for_status_filter" do
    context "when the passed status category is 'all'" do
      it "returns all project records" do
        invoices = create_pair(:invoice)

        results = Invoice.for_status_filter("all")

        expect(results).to match_array invoices
      end
    end

    context "when the passed status category is something other than 'all'" do
      it "returns the project records where the status maps to the status category" do
        invoice1 = create(:invoice, balance_due: 10)
        invoice2 = create(:invoice, balance_due: 0)
        invoice3 = create(:invoice, balance_due: 10)

        results = Invoice.for_status_filter("balance_due")

        expect(results).to match_array [invoice1, invoice3]
      end
    end
  end

  describe ".with_invoices_at_reserve" do
    let(:reserve1) { create(:reserve) }
    let(:reserve2) { create(:reserve) }
    let(:user) { create(:user, managed_reserves: [reserve1, reserve2]) }

    it "if reserve is present returns invoices that have visits on the given reserve" do
      visit1 = create(:visit, reserve: reserve1)
      visit2 = create(:visit, reserve: reserve2)
      visit3 = create(:visit, reserve: reserve1)

      invoice1 = create(:invoice, visit: visit1)
      invoice2 = create(:invoice, visit: visit2)
      invoice3 = create(:invoice, visit: visit1)

      results = Invoice.with_invoices_at_reserve(reserve1)

      expect(results).to eq [invoice1, invoice3]
    end

    it "if reserve is not present returns all invoices" do
      visit1 = create(:visit, reserve: reserve1)
      visit2 = create(:visit, reserve: reserve2)
      visit3 = create(:visit, reserve: reserve1)

      invoice1 = create(:invoice, visit: visit1)
      invoice2 = create(:invoice, visit: visit2)
      invoice3 = create(:invoice, visit: visit1)

      results = Invoice.with_invoices_at_reserve(nil)

      expect(results.to_a).to eq [invoice1, invoice2, invoice3]
    end
  end

  describe ".having_between_time_for" do
    it "calls the .having_visit_end_date_after and .having_visit_start_date_before when supplied date_range_option is ':visit_date_range'" do
      date1 = Date.new(1969, 7, 20)
      date2 = Date.new(1980, 7, 31)

      visit1 = create(:visit, starts_at: Date.new(1969, 7, 21), ends_at: Date.new(1980, 7, 30))
      visit2 = create(:visit, starts_at: Date.new(1981, 7, 20), ends_at: Date.new(1981, 10, 31))
      visit3 = create(:visit, starts_at: Date.new(1969, 7, 25), ends_at: Date.new(1980, 7, 20))

      invoice1 = create(:invoice, balance_due: 10, visit: visit1)
      invoice2 = create(:invoice, balance_due: 0, visit: visit2)
      invoice3 = create(:invoice, balance_due: 10, visit: visit3)

      results = Invoice.having_between_time_for(
        date_range_option: :visit_date_range,
        date_start: date1,
        date_end: date2,
      )

      expect(results.map(&:id)).to eq [invoice1.id, invoice3.id]
    end

    it "calls the .having_invoiced_date_after and .having_invoiced_date_before when supplied date_range_option is ':invoiced_on'" do
      date1 = Date.new(1969, 7, 20)
      date2 = Date.new(1980, 7, 31)

      invoice1 = create(:invoice, balance_due: 10, invoiced_on: Date.new(1969, 7, 21))
      invoice2 = create(:invoice, balance_due: 0, invoiced_on: Date.new(1980, 8, 31))
      invoice3 = create(:invoice, balance_due: 10, invoiced_on: Date.new(1980, 7, 30))

      results = Invoice.having_between_time_for(
        date_range_option: :invoiced_on, 
        date_start: date1,
        date_end: date2,
      )
      expect(results.map(&:id)).to eq [invoice1.id, invoice3.id]
    end

    it "returns self.all when supplied date_range_option doesn't match any case" do
      date1 = Date.new(1969, 7, 20)
      date2 = Date.new(1980, 7, 31)

      results = Invoice.having_between_time_for(date_range_option: :non_existent_case, date_start: date1, date_end: date2)

      expect(results).to eq Invoice.all
    end
  end
end
