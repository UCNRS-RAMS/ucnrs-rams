require "rails_helper"

RSpec.describe InvoiceRecipient do
  describe "associations" do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:invoice) }
  end
end
