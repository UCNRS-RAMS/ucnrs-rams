require "rails_helper"

RSpec.describe Manager::Invoices::InvoiceShowPresenter do
  let(:project) { create(:project) }
  let(:reserve) { create(:reserve) }
  let(:visit) { create(:visit, reserve: reserve, project: project) }
  let(:invoice) { create(:invoice, visit: visit) }
  let(:user) { create(:user, :confirmed) }

  describe "delegations" do
    subject { Manager::Invoices::InvoiceShowPresenter.new(invoice: invoice, current_user: user) }
    it { is_expected.to delegate_method(:name).to(:reserve).with_prefix(true) }
    it { is_expected.to delegate_method(:title).to(:project).with_prefix(true) }
    it { is_expected.to delegate_method(:id).to(:invoice).with_prefix(true) }
    it { is_expected.to delegate_method(:purpose_of_visit).to(:visit) }
    it { is_expected.to delegate_method(:notes).to(:invoice) }
  end

  describe "#title" do
    it "return invoice title with invoice id and version" do
      presenter = Manager::Invoices::InvoiceShowPresenter.new(invoice: invoice, current_user: user)
      output = "Invoice #{invoice.id}-#{invoice.modify_number}"

      expect(presenter.title).to eq output
    end
  end

  describe "#amenities_total" do
    it "return amenity_visits total of invoice" do
      amenity_visit = create(:amenity_visit, invoice_id: invoice.id, rate: 10)
      presenter = Manager::Invoices::InvoiceShowPresenter.new(invoice: invoice, current_user: user)
      output =  "$%0.2f" % [amenity_visit.subtotal]

      expect(presenter.amenities_total).to eq output
    end
  end

  describe "#visit_date_range" do
    it "return date range of visit" do
      presenter = Manager::Invoices::InvoiceShowPresenter.new(invoice: invoice, current_user: user)
      output = Manager::VisitShowPresenter.new(visit: visit, current_user: user).visit_date_range

      expect(presenter.visit_date_range).to eq output
    end
  end

  describe "#amenity_visit_presenters" do
    it "return array of amenity_visit_presenters of invoice" do
      amenity_visit_one = create(:amenity_visit, invoice_id: invoice.id)
      amenity_visit_two = create(:amenity_visit, invoice_id: invoice.id)
      presenter = Manager::Invoices::InvoiceShowPresenter.new(invoice: invoice, current_user: user)

      expect(presenter.amenity_visit_presenters).to all(be_instance_of AmenityVisitPresenter)
    end
  end

  describe "#recipients" do
    it "return invoice_recipient's team_memberships of invoice" do
      team_membership = create(:project_team_membership, :principal_investigator, user: user, project: project)
      invoice_recipient = create(:invoice_recipient, user_id: team_membership.user_id, invoice_id: invoice.id)

      presenter = Manager::Invoices::InvoiceShowPresenter.new(invoice: invoice, current_user: user)

      output = [team_membership.id]

      expect(presenter.recipients.pluck(:id)).to eq output
    end
  end

  describe "#link_params" do
    it "return hash of params" do
      presenter = Manager::Invoices::InvoiceShowPresenter.new(invoice: invoice, current_user: user)

      output = { classes: nil, path: "xyz", method: nil, data: nil, icon: "delete-icon", icon_alt: nil }

      expect(presenter.link_params(path: "xyz", icon: "delete-icon")).to eq output
    end
  end

  describe "#balance" do
    it "return amenity_visits total of invoice" do
      amenity_visit = create(:amenity_visit, invoice_id: invoice.id, rate: 10)
      invoice_payment = create(:invoice_payment, invoice: invoice, user: user, amount: 1000)
      presenter = Manager::Invoices::InvoiceShowPresenter.new(invoice: invoice, current_user: :user)
      amenity_visit_total = format("%0.2f", invoice.amenity_visits.sum(&:subtotal)).to_i
      payments_amount_total = format("%0.2f", invoice.invoice_payments.pluck(:amount).sum).to_i
      output = (amenity_visit_total - payments_amount_total)

      expect(presenter.balance).to eq output
    end
  end

  describe "#balance_class" do
    let(:presenter) { Manager::Invoices::InvoiceShowPresenter.new(invoice: invoice, current_user: :user) }

    context "when the balance is negative" do
      before do
        allow(presenter).to receive(:calculate_balance).and_return(-100)
      end

      it "returns 'negative_balance'" do
        expect(presenter.balance_class).to eq "negative_balance"
      end
    end

    context "when the balance is positive" do
      before do
        allow(presenter).to receive(:calculate_balance).and_return(100)
      end

      it "returns 'positive_balance'" do
        expect(presenter.balance_class).to eq "positive_balance"
      end
    end

    context "when the balance is zero" do
      before do
        allow(presenter).to receive(:calculate_balance).and_return(0)
      end

      it "returns 'default_balance'" do
        expect(presenter.balance_class).to eq "default_balance"
      end
    end
  end

  describe "#invoice_payments" do
    context "when invoice has payments" do
      let!(:invoice_payment1) { create(:invoice_payment, invoice: invoice) }
      let!(:invoice_payment2) { create(:invoice_payment, invoice: invoice) }
      let!(:presenter) { Manager::Invoices::InvoiceShowPresenter.new(invoice: invoice, current_user: :user) }

      it "returns an array of InvoicePaymentPresenter objects" do
        invoice_payments = presenter.invoice_payments
        expect(invoice_payments).to be_an(Array)
        expect(invoice_payments).to all(be_an(InvoicePaymentPresenter))
      end
    end

    context "when invoice has no payments" do
      it "returns an empty array" do
        invoice_payments = invoice.invoice_payments
        expect(invoice_payments).to be_empty
      end
    end
  end
end
