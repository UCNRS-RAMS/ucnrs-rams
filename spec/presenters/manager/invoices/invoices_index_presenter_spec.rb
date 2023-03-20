require "rails_helper"

RSpec.describe Manager::InvoicesIndexPresenter do
  describe "#invoices" do
    let(:reserve1) { create(:reserve) }
    let(:reserve2) { create(:reserve) }
    let(:user) { create(:user, managed_reserves: [reserve1, reserve2]) }

    it "presents the invoices records" do
      visit1 = create(:visit, reserve: reserve1)
      visit2 = create(:visit, reserve: reserve2)
      visit3 = create(:visit, reserve: reserve1)

      invoice1 = create(:invoice, visit: visit1)
      invoice2 = create(:invoice, visit: visit2)
      invoice3 = create(:invoice, visit: visit1)

      presenter = Manager::InvoicesIndexPresenter.new( user: user )

      expect(presenter.invoices.map(&:id)).to match_array([invoice1.id, invoice2.id, invoice3.id])
    end
  end

  describe "#reserve_options" do
    it "return reserve options" do
      reserve1 = create(:reserve, name: "Reserve 1")
      reserve2 = create(:reserve, name: "Reserve 2")
      reserve3 = create(:reserve, name: "Reserve 3")
      user = create(:user, managed_reserves: [reserve1, reserve2, reserve3])

      presenter = Manager::InvoicesIndexPresenter.new(user: user)
      output = { "All"=>nil, "Reserve 1"=>reserve1.id, "Reserve 2"=>reserve2.id, "Reserve 3"=>reserve3.id }

      expect(presenter.reserve_options).to eq output
    end
  end

  describe "#invoice_status_options" do
    it "returns status options for invoice filter" do
      presenter = Manager::InvoicesIndexPresenter.new
      output = { "All" => nil, "Paid" => :paid, "Pending" => :due }

      expect(presenter.invoice_status_options).to eq output
    end
  end

  describe "#sort_by_options" do
    it "returns sort options for invoice filter" do
      presenter = Manager::InvoicesIndexPresenter.new
      output = {
        "Date Created" => :created_recent_first,
        "Amount" => :sort_by_amount,
        "Balance Due" => :sort_by_balance_due,
        "Invoice Number" => :sort_by_invoice_number,
      }

      expect(presenter.sort_by_options).to eq output
    end
  end
end
