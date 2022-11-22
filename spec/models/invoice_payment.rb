require "rails_helper"

RSpec.describe InvoicePayment, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:invoice) }
    it { is_expected.to belong_to(:user) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:amount) }
    it { is_expected.to validate_presence_of(:paid_on) }
  end
end
