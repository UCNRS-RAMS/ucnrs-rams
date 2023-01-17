require "rails_helper"

RSpec.describe InvoiceRecipient do
  describe "associations" do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:invoice) }
  end

  describe "destroy" do
    it "will do soft deletion for invoice_recipient" do
      invoice_recipient = create(:invoice_recipient)

      expect(invoice_recipient.deleted_at).to eq nil

      invoice_recipient.destroy

      expect(invoice_recipient.deleted_at).not_to eq nil
    end
  end
end
