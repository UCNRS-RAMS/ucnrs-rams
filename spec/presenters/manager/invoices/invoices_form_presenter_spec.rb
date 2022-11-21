require "rails_helper"

RSpec.describe Manager::Invoices::InvoicesFormPresenter do
  let(:visit) { create(:visit) }
  let(:invoice) { create(:invoice, visit: visit) }

  describe "delegations" do
    subject { Manager::Invoices::InvoicesFormPresenter.new(visit: visit, form: InvoiceForm.new(invoice: invoice, params: { visit_id: visit.id })) }
    it { is_expected.to delegate_missing_methods_to(:visit) }
    it { is_expected.to delegate_method(:amenities_total).to(:form) }
    it { is_expected.to delegate_method(:id).to(:form) }
  end

  describe "#amenity_presenter" do
    it "return amenity_presenter" do
      form = InvoiceForm.new(params: {visit_id: create(:visit).id})
      visit = create(:visit)
      amenity = create(:amenity)
      amenity_visit = create(:amenity_visit, amenity: amenity)

      presenter = Manager::Invoices::InvoicesFormPresenter.new(visit: visit, form: form)
      output = Visits::AmenityPresenter.new(amenity, form: [amenity_visit])

      expect(presenter.amenity_presenter(amenity, amenity_visit).amenity.id).to eq output.amenity.id
      expect(presenter.amenity_presenter(amenity, amenity_visit).form.first.id).to eq output.form.first.id
    end
  end

  describe "#visit_date_range" do
    it "return visit date range" do
      starts_at = 3.weeks.ago
      ends_at = 3.week.from_now

      visit = create(:visit, starts_at: starts_at, ends_at: ends_at)
      form = InvoiceForm.new(params: {visit_id: visit.id})
      presenter = Manager::Invoices::InvoicesFormPresenter.new(visit: visit, form: form)
      output = DateRangePresenter.value(start_date: starts_at.to_date, end_date: ends_at.to_date)

      expect(presenter.visit_date_range).to eq output
    end
  end

  describe "#project_team_members" do
    it "returns an array of Manager::Projects::TeamMembershipPresenter" do
      project = create(:project)
      visit = create(:visit, project: project)
      form = InvoiceForm.new(params: {visit_id: visit.id})
      create(:project_team_membership, project: project, can_receive_invoice: true)
      create(:project_team_membership, project: project, can_receive_invoice: true)

      presenter = Manager::Invoices::InvoicesFormPresenter.new(visit: visit, form: form)

      expect(presenter.project_team_members).to all(be_instance_of Manager::Projects::TeamMembershipPresenter)
    end
  end
end
