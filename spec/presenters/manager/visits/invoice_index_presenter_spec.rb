require "rails_helper"

RSpec.describe Manager::Visits::InvoicesIndexPresenter do
  let(:project) { create(:project) }
  let(:reserve) { create(:reserve) }
  let(:visit) { create(:visit, reserve: reserve, project: project) }
  let(:invoice) { create(:invoice, visit: visit) }
  let(:user) { create(:user, :confirmed) }

  describe "delegations" do
    subject { Manager::Visits::InvoicesIndexPresenter.new(visit: visit, user: user, form: InvoiceForm.new(params: {visit_id: visit.id})) }
    it { is_expected.to delegate_missing_methods_to(:visit) }
  end

  describe "#selected_invoices" do
    it "return invoices of the visit" do
      create(:invoice, visit: visit)
      form = InvoiceForm.new(params: {visit_id: visit.id})
      presenter = Manager::Visits::InvoicesIndexPresenter.new(visit: visit, user: user, form: form)
      result = presenter.selected_invoices

      expect(result).to all(be_instance_of(InvoicePresenter))
    end
  end

  describe "#invoice_filter_options" do
    it "return invoice filter options" do
      create(:invoice, visit: visit)
      form = InvoiceForm.new(params: {visit_id: visit.id})
      presenter = Manager::Visits::InvoicesIndexPresenter.new(visit: visit, user: user, form: form)
      output = {"visit_invoices"=>"visit_invoices", "project_invoices"=>"project_invoices"}

      expect(presenter.invoice_filter_options).to eq output
    end
  end

  describe "#invoice_selected" do
    it "return 'selected' if invoice_filter is equal to given option" do
      form = InvoiceForm.new(params: {visit_id: visit.id})
      presenter = Manager::Visits::InvoicesIndexPresenter.new(visit: visit, user: user, form: form, invoice_filter: "visit_invoices" )
      output = "selected"

      expect(presenter.invoice_selected("visit_invoices")).to eq output
    end

    it "return '' if invoice_filter is not equal to given option" do
      form = InvoiceForm.new(params: {visit_id: visit.id})
      presenter = Manager::Visits::InvoicesIndexPresenter.new(visit: visit, user: user, form: form, invoice_filter: "visit_invoices" )
      output = ""

      expect(presenter.invoice_selected("project_invoices")).to eq output
    end
  end

  describe "#reserve_manager?" do
    it "return true if current user is a staff member of reserve" do
      create(:reserve_personnel, user: user, reserve: reserve)
      form = InvoiceForm.new(params: {visit_id: visit.id})
      presenter = Manager::Visits::InvoicesIndexPresenter.new(visit: visit, user: user, form: form)

      expect(presenter.reserve_manager?(reserve)).to eq true
    end

    it "return false if current user is not a staff member of reserve" do
      reserve = create(:reserve)
      form = InvoiceForm.new(params: {visit_id: visit.id})
      presenter = Manager::Visits::InvoicesIndexPresenter.new(visit: visit, user: user, form: form)

      expect(presenter.reserve_manager?(reserve)).to eq false
    end
  end

  describe "#visit_total" do
    it "return amenity_visits total of invoice" do
      invoice = create(:invoice, visit: visit)
      create(:amenity_visit, visit: visit, invoice_id: invoice.id, number_of_people: 10, manual_units_of_time: 10, rate: 10)
      create(:amenity_visit, visit: visit, invoice_id: invoice.id, number_of_people: 10, manual_units_of_time: 10, rate: 10)
      form = InvoiceForm.new(params: {visit_id: visit.id})
      presenter = Manager::Visits::InvoicesIndexPresenter.new(visit: visit, user: user, form: form)
      output = "$2,000.00"

      expect(presenter.visit_total).to eq output
    end
  end

  describe "#invoiced" do
    it "return amenity_visits total of invoiced amenity_visits" do
      invoice = create(:invoice, visit: visit)
      create(:amenity_visit, visit: visit, number_of_people: 10, manual_units_of_time: 10, rate: 10, invoice: invoice)
      create(:amenity_visit, visit: visit, number_of_people: 10, manual_units_of_time: 10, rate: 10)
      form = InvoiceForm.new(params: {visit_id: visit.id})
      presenter = Manager::Visits::InvoicesIndexPresenter.new(visit: visit, user: user, form: form)
      output = "$1,000.00"

      expect(presenter.invoiced).to eq output
    end
  end

  describe "#paid" do
    it "return total of invoice payments" do
      invoice = create(:invoice, visit: visit)
      create(:amenity_visit, visit: visit, invoice_id: invoice.id, number_of_people: 10, manual_units_of_time: 10, rate: 10, invoice: invoice)
      create(:amenity_visit, visit: visit, invoice_id: invoice.id, number_of_people: 10, manual_units_of_time: 10, rate: 10)
      create(:invoice_payment, invoice: invoice, user: user, amount: 5)
      create(:invoice_payment, invoice: invoice, user: user, amount: 10)
      form = InvoiceForm.new(params: {visit_id: visit.id})
      presenter = Manager::Visits::InvoicesIndexPresenter.new(visit: visit, user: user, form: form)
      output = "-$15.00"

      expect(presenter.paid).to eq output
    end
  end

  describe "#total_balance" do
    it "return amenity_visits total of invoice" do
      invoice = create(:invoice, visit: visit)
      create(:amenity_visit, visit: visit, invoice_id: invoice.id, number_of_people: 10, manual_units_of_time: 10, rate: 10, invoice: invoice)
      create(:amenity_visit, visit: visit, invoice_id: invoice.id, number_of_people: 10, manual_units_of_time: 10, rate: 10)
      create(:invoice_payment, invoice: invoice, user: user, amount: 5)
      create(:invoice_payment, invoice: invoice, user: user, amount: 10)
      form = InvoiceForm.new(params: {visit_id: visit.id})
      presenter = Manager::Visits::InvoicesIndexPresenter.new(visit: visit, user: user, form: form)
      output = "$1,985.00"

      expect(presenter.total_balance).to eq output
    end
  end
end
