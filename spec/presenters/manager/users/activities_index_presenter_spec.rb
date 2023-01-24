require "rails_helper"

RSpec.describe Manager::Users::ActivitiesIndexPresenter do
  describe "delegations" do
    subject { Manager::Users::ActivitiesIndexPresenter.new() }
    it { is_expected.to delegate_missing_methods_to(:user) }
    it { is_expected.to delegate_method(:id).to(:user).with_prefix(true) }
    it { is_expected.to delegate_method(:full_name).to(:user).with_prefix(true) }
    it { is_expected.to delegate_method(:institution).to(:user).with_prefix(true) }
    it { is_expected.to delegate_method(:name).to(:user_institution).with_prefix(true) }
    it { is_expected.to delegate_method(:institution_type).to(:user_institution) }
  end

  describe "#user" do
    it "presents the user records wrapped in Manager::UserShowPresenter" do
      user = create(:user)
      presenter = Manager::Users::ActivitiesIndexPresenter.new(user: user)

      user = presenter.user

      expect(user.id).to eq user.id
      expect(user).to be_a(UserPresenter)
    end
  end

  describe "#reserve_manager?" do
    it "return true if current user is a staff member of reserve" do
      user = create(:user, :confirmed)
      reserve = create(:reserve)
      create(:reserve_personnel, user: user, reserve: reserve)
      presenter = Manager::Users::ActivitiesIndexPresenter.new(user: user)

      expect(presenter.reserve_manager?(reserve)).to eq true
    end
    
    it "return false if current user is not a staff member of reserve" do
      user = create(:user, :confirmed)
      reserve = create(:reserve)
      presenter = Manager::Users::ActivitiesIndexPresenter.new(user: user)

      expect(presenter.reserve_manager?(reserve)).to eq false
    end
  end

  describe "#visits" do
    it "presents the visits records wrapped in VisitPresenter" do
      user = create(:user)
      visit1 = create(:visit, user: user)
      visit2 = create(:visit, user: user)
      visit3 = create(:visit)
      presenter = Manager::Users::ActivitiesIndexPresenter.new(user: user)

      visits = presenter.visits

      expect(visits.map(&:id)).to match_array [visit1.id, visit2.id]
      expect(visits).to all(be_a(VisitPresenter))
    end
  end

  describe "#projects" do
    it "presents the projects records wrapped in ProjectPresenter" do
      user = create(:user)
      project1 = create(:project, members: [user])
      project2 = create(:project, members: [user])
      project3 = create(:project)
      presenter = Manager::Users::ActivitiesIndexPresenter.new(user: user)

      projects = presenter.projects

      expect(projects.map(&:id)).to match_array [project1.id, project2.id]
      expect(projects).to all(be_a(ProjectPresenter))
    end
  end

  describe "#invoices" do
    it "presents the invoices records wrapped in InvoicePresenter" do
      user = create(:user)
      invoice1 = create(:invoice, recipients: [user])
      invoice2 = create(:invoice, recipients: [user])
      invoice3 = create(:invoice)
      presenter = Manager::Users::ActivitiesIndexPresenter.new(user: user)

      invoices = presenter.invoices

      expect(invoices.map(&:id)).to match_array [invoice1.id, invoice2.id]
      expect(invoices).to all(be_a(InvoicePresenter))
    end
  end

  describe "#visit_scope" do
    it "returns only visits with applicant or user_visit matching given user" do
      user = create(:user)
      visit1 = create(:visit, user: user)
      visit2 = create(:visit)
      create(:user_visit, visit: visit2, user: user)
      visit3 = create(:visit)
      presenter = Manager::Users::ActivitiesIndexPresenter.new(user: user)

      visit_scope = presenter.visit_scope

      expect(visit_scope).to match_array [visit1, visit2]
    end


    it "returns visits sorted by latest user visit date first" do
      user = create(:user)
      visit1 = create(:visit, starts_at: 1.year.ago, user: user)
      create(:user_visit, visit: visit1, arrives_at: 3.week.ago)
      visit2 = create(:visit, starts_at: 1.year.ago, user: user)
      create(:user_visit, visit: visit2, arrives_at: 1.week.ago)
      visit3 = create(:visit, starts_at: 1.year.ago, user: user)
      create(:user_visit, visit: visit3, arrives_at: 2.week.ago)
      presenter = Manager::Users::ActivitiesIndexPresenter.new(user: user)

      visit_scope = presenter.visit_scope

      expect(visit_scope).to eq [visit2, visit3, visit1]
    end

    it "returns a maximum of 6 visits" do
      user = create(:user)
      create_list(:visit, 8, user: user)
      presenter = Manager::Users::ActivitiesIndexPresenter.new(user: user, visits_page: 1)

      visit_scope = presenter.visit_scope

      expect(visit_scope.length).to eq 6
    end
  end

  describe "#project_scope" do
    it "returns only projects with team_membership matching given user" do
      user = create(:user)
      project1 = create(:project, applicant: user)
      project2 = create(:project, members: [user])
      project3 = create(:project, members: [user])
      presenter = Manager::Users::ActivitiesIndexPresenter.new(user: user)

      project_scope = presenter.project_scope

      expect(project_scope).to match_array [project2, project3]
    end

    it "returns a maximum of 6 visits" do
      user = create(:user)
      create_list(:project, 8, members: [user])
      presenter = Manager::Users::ActivitiesIndexPresenter.new(user: user, projects_page: 1)

      project_scope = presenter.project_scope

      expect(project_scope.length).to eq 6
    end
  end

  describe "#invoice_scope" do
    it "returns only invoices with invoice_recipient matching given user" do
      user = create(:user)
      invoice1 = create(:invoice)
      invoice2 = create(:invoice, recipients: [user])
      invoice3 = create(:invoice, recipients: [user])
      presenter = Manager::Users::ActivitiesIndexPresenter.new(user: user)

      invoice_scope = presenter.invoice_scope

      expect(invoice_scope).to match_array [invoice2, invoice3]
    end

    it "returns invoices sorted by latest created_at first" do
      user = create(:user)
      invoice1 = create(:invoice, recipients: [user], created_at: 3.week.ago)
      invoice2 = create(:invoice, recipients: [user], created_at: 1.week.ago)
      invoice3 = create(:invoice, recipients: [user], created_at: 2.week.ago)
      presenter = Manager::Users::ActivitiesIndexPresenter.new(user: user)

      invoice_scope = presenter.invoice_scope

      expect(invoice_scope).to eq [invoice2, invoice3, invoice1]
    end

    it "returns a maximum of 6 invoices" do
      user = create(:user)
      create_list(:invoice, 8, recipients: [user])
      presenter = Manager::Users::ActivitiesIndexPresenter.new(user: user, invoices_page: 1)

      invoice_scope = presenter.invoice_scope

      expect(invoice_scope.length).to eq 6
    end
  end
end
