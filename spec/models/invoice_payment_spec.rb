require "rails_helper"

RSpec.describe InvoicePayment, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:invoice) }
    it { is_expected.to have_many(:logs) }
  end
end
