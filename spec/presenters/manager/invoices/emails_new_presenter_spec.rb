require "rails_helper"

RSpec.describe Manager::Invoices::EmailsNewPresenter do
  describe "delegations" do
    subject { Manager::Invoices::EmailsNewPresenter.new(invoice: :invoice) }
    it { is_expected.to delegate_method(:id).to(:invoice).with_prefix(true) }
    it { is_expected.to delegate_method(:visit).to(:invoice).with_prefix(true) }
    it { is_expected.to delegate_method(:reserve).to(:invoice_visit).with_prefix(true) }
  end

  describe "#invoice_visit_project_team_membership" do
    it "return invoice associated projects team members records wrapped in ProjectTeamMembershipPresenter" do
      project = create(:project)
      team_memberships = create_list(:project_team_membership, 3, project: project)
      visit = create(:visit, project: project)
      invoice = create(:invoice, visit: visit)
      presenter = Manager::Invoices::EmailsNewPresenter.new(invoice: invoice)

      invoice_visit_project_team_membership = presenter.invoice_visit_project_team_membership

      expect(invoice_visit_project_team_membership.map(&:id)).to match_array [
        team_memberships[0].id,
        team_memberships[1].id,
        team_memberships[2].id,
      ]
      expect(invoice_visit_project_team_membership).to all(be_a(ProjectTeamMembershipPresenter))
    end
  end

  describe "#email_default_subject" do
    it "return a string for default email subject" do
      reserve = create(:reserve, name: "Reserve XYZ")
      visit = create(:visit, reserve: reserve)
      invoice = create(:invoice, visit: visit)
      presenter = Manager::Invoices::EmailsNewPresenter.new(invoice: invoice)

      email_default_subject = presenter.email_default_subject

      expect(email_default_subject).to eq "Invoice ##{invoice.id} - Reserve XYZ"
    end
  end

  describe "#email_attachment_name" do
    context "when there is only one principal investigators" do
      it "return a string for the attachment pdf name" do
        project = create(:project)
        user1 = create(:user, first_name: "mr", last_name: "abc")
        team_membership1 = create(:project_team_membership,
          project: project, user: user1, is_principal_investigator: true
        )
        visit = create(:visit, project: project)
        invoice = create(:invoice, visit: visit)
        presenter = Manager::Invoices::EmailsNewPresenter.new(invoice: invoice)

        email_attachment_name = presenter.email_attachment_name

        expect(email_attachment_name).to eq "rams_invoice_mr_abc_#{invoice.id}.pdf"
      end
    end

    context "when there are more than one principal investigators" do
      it "return a string for the attachment pdf name" do
        project = create(:project)
        user1 = create(:user, first_name: "mr", last_name: "abc")
        user2 = create(:user, first_name: "mr", last_name: "xyz")
        team_membership1 = create(:project_team_membership,
          project: project, user: user1, is_principal_investigator: true
        )
        team_membership2 = create(:project_team_membership,
          project: project, user: user2, is_principal_investigator: true
        )
        visit = create(:visit, project: project)
        invoice = create(:invoice, visit: visit)
        presenter = Manager::Invoices::EmailsNewPresenter.new(invoice: invoice)

        email_attachment_name = presenter.email_attachment_name

        expect(email_attachment_name).to eq "rams_invoice_mr_abc_et_al_#{invoice.id}.pdf"
      end
    end
  end
end
