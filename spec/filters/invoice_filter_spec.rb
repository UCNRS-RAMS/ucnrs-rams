require "rails_helper"

RSpec.describe InvoiceFilter do
  describe "#invoice_search_filter" do
    context "if :sort_by is present" do
      it "returns a strip :invoice_search" do
        filter = { invoice_search: "  keyword  " }
        invoice_filter = InvoiceFilter.new(filter, nil)

        result = invoice_filter.invoice_search_filter

        expect(result).to eq "keyword"
      end
    end

    context "if :sort_by is not present" do
      it "returns a strip :invoice_search" do
        filter = { invoice_search: "" }
        invoice_filter = InvoiceFilter.new(filter, nil)

        result = invoice_filter.invoice_search_filter

        expect(result).to eq ""
      end
    end
  end

  describe "#sort_by_filter" do
    context "if :sort_by is present" do
      it "returns :sort_by" do
        filter = { sort_by: "keyword" }
        invoice_filter = InvoiceFilter.new(filter, nil)

        result = invoice_filter.sort_by_filter

        expect(result).to eq "keyword"
      end
    end

    context "if :sort_by is not present" do
      it "returns 'submitted_recent_first'" do
        filter = { sort_by: "" }
        invoice_filter = InvoiceFilter.new(filter, nil)

        result = invoice_filter.sort_by_filter

        expect(result).to eq "created_recent_first"
      end
    end
  end

  describe "#reserve_filter" do
    context "if :filter is nil" do
      it "returns given reserve.id" do
        filter = { reserve: nil }
        reserve = create(:reserve)
        invoice_filter = InvoiceFilter.new(filter, reserve)

        result = invoice_filter.reserve_filter

        expect(result).to eq reserve.id
      end
    end

    context "if :filter is not nil" do
      it "returns :filter" do
        filter = { reserve: "1" }
        invoice_filter = InvoiceFilter.new(filter, nil)

        result = invoice_filter.reserve_filter

        expect(result).to eq "1"
      end
    end
  end

  describe "#invoice_begin_filter" do
    it "returns :invoice_date_begin" do
      filter = { invoice_date_begin: "a date" }
      invoice_filter = InvoiceFilter.new(filter, nil)

      result = invoice_filter.invoice_date_begin_filter

      expect(result).to eq "a date"
    end
  end

  describe "#invoice_date_end_filter" do
    it "returns :invoice_date_end" do
      filter = { invoice_date_end: "a date" }
      invoice_filter = InvoiceFilter.new(filter, nil)

      result = invoice_filter.invoice_date_end_filter

      expect(result).to eq "a date"
    end
  end

  describe "#visit_date_begin_filter" do
    it "returns :visit_date_begin" do
      filter = { visit_date_begin: "a date" }
      invoice_filter = InvoiceFilter.new(filter, nil)

      result = invoice_filter.visit_date_begin_filter

      expect(result).to eq "a date"
    end
  end

  describe "#visit_date_end_filter" do
    it "returns :visit_date_end" do
      filter = { visit_date_end: "a date" }
      invoice_filter = InvoiceFilter.new(filter, nil)

      result = invoice_filter.visit_date_end_filter
  
      expect(result).to eq "a date"
    end
  end

  describe "#invoice_status_filter" do
    context "if :invoice_status is present" do
      it "returns given :invoice_status" do
        filter = { invoice_status: "a invoice status" }
        invoice_filter = InvoiceFilter.new(filter, nil)

        result = invoice_filter.invoice_status_filter
    
        expect(result).to eq "a invoice status"
      end
    end

    context "if :invoice_status is not present" do
      it "returns 'all'" do
        filter = { invoice_status: "" }
        invoice_filter = InvoiceFilter.new(filter, nil)

        result = invoice_filter.invoice_status_filter
    
        expect(result).to eq "all"
      end
    end
  end
end
