require "rails_helper"

RSpec.describe InvoicePresenter do
  describe "delegations" do
    subject { InvoicePresenter.new(Invoice.new(1, "paid", "Here", 10000)) }
    it { is_expected.to delegate_method(:id).to(:invoice) }
    it { is_expected.to delegate_method(:status).to(:invoice) }
    it { is_expected.to delegate_method(:requested_reserve_name)
      .to(:invoice).as(:name) }
  end

  describe "#amount" do
    def presenting_amount(amount)
      InvoicePresenter.new(
        Invoice.new(1, "paid", "Here", amount)
      )
    end

    it "formats the number as a dollar value" do
      presenter = presenting_amount(123456)

      output = presenter.amount

      expect(output).to eq "$1,234.56"
    end
  end
end
