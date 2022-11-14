require "rails_helper"

RSpec.describe Invoice, type: :model do
  describe "associations" do
    it { is_expected.to have_many(:invoice_recipients) }
    it { is_expected.to have_many(:users).through(:invoice_recipients) }
  end
end
