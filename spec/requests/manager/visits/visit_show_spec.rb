require "rails_helper"

RSpec.describe "Manager visit show", type: :request do
  let(:manager) { create(:user, :confirmed) }
  let(:reserve) { create(:reserve, name: "Test Reserve") }
  let(:visit) { create(:visit, reserve: reserve) }

  before do
    create(:reserve_personnel, user: manager, reserve: reserve)
    sign_in(manager)
  end

  describe "GET /manager/reserves/:reserve_id/visits/:id" do
    it "renders the summary box and menu bar for the visit" do
      get manager_reserve_visit_path(reserve, visit)

      expect(response).to be_ok
      doc = Capybara.string(response.body)
      expect(doc).to have_css("body.manager")
      expect(doc).to have_css(".visit-summary-box")
      expect(doc).to have_css("#trash-icon")
      expect(doc).to have_css("#trash-icon[href='#{manager_reserve_visit_invoice_index_path(visit_id: visit.id)}']")
      expect(doc).to have_css(".visit-menu-bar")
      expect(doc).to have_css(".visit-menu-bar #summary")
      expect(doc).to have_css(".visit-menu-bar #details")
      expect(doc).to have_css(".visit-menu-bar #visitors")
      expect(doc).to have_css(".visit-menu-bar #reserve_info")
      expect(doc).to have_css(".visit-menu-bar #invoices")
      expect(doc).to have_css("turbo-frame#visit-details[src*='/summary']")
    end

    it "redirects a user who does not manage any reserve" do
      sign_in(create(:user, :confirmed))

      get manager_reserve_visit_path(reserve, visit)

      expect(response).to redirect_to(root_url)
      expect(flash[:notice]).to eq(I18n.translate("manager.not_a_manager"))
    end
  end

  describe "GET /manager/reserves/:reserve_id/visits/:visit_id/summary" do
    it "renders the visit summary with its visitors and amenities" do
      visitor = create(:user, :confirmed)
      create(:user_visit, visit: visit, user: visitor)
      create(:amenity_visit, visit: visit)

      get manager_reserve_visit_summary_path(reserve, visit)

      expect(response).to be_ok
      doc = Capybara.string(response.body)
      expect(doc).to have_css(".visit-summary-show")
      expect(doc).to have_css("turbo-frame#visit-summary-edit[src*='/summary/edit']")
      expect(doc).to have_css("table#team-summary-table", text: visitor.full_name)
      expect(doc).to have_css("#amenities-summary-table")
    end
  end

  describe "GET /manager/reserves/:reserve_id/visits/:visit_id/summary/edit" do
    it "renders the email composition fields by default" do
      get edit_manager_reserve_visit_summary_path(reserve, visit)

      expect(response).to be_ok
      doc = Capybara.string(response.body)
      expect(doc).to have_css("turbo-frame#visit-summary-edit")
      expect(doc).to have_css("select.email-notification-method")
      expect(doc).to have_css("textarea.email-message")
    end

    it "disables the status buttons while the visit is incomplete" do
      get edit_manager_reserve_visit_summary_path(reserve, visit)

      doc = Capybara.string(response.body)
      expect(doc).to have_css("input#incomplete[checked]")
      expect(doc).to have_css("input#approved[disabled]")
      expect(doc).to have_css("input#denied[disabled]")
    end

    it "leaves the status buttons enabled once the visit is no longer incomplete" do
      visit = create(:visit, reserve: reserve, status: "approved")

      get edit_manager_reserve_visit_summary_path(reserve, visit)

      doc = Capybara.string(response.body)
      expect(doc).to have_css("input#approved")
      expect(doc).not_to have_css("input#approved[disabled]")
      expect(doc).not_to have_css("input#denied[disabled]")
    end
  end

  describe "GET /manager/reserves/:reserve_id/visits/:visit_id/detail/edit" do
    it "renders the visit details without editable project fields" do
      get edit_manager_reserve_visit_detail_path(reserve, visit)

      expect(response).to be_ok
      doc = Capybara.string(response.body)
      expect(doc).to have_css(".visit-detail-edit")
      expect(doc).to have_css(".display-link", text: visit.project.title)
      expect(doc).not_to have_css("#visit_project_id")
      expect(doc).not_to have_css("#project-type-research")
    end
  end

  describe "GET /manager/reserves/:reserve_id/visits/:visit_id/user_visits" do
    it "renders the visitors list and the add team member form" do
      visitor = create(:user, :confirmed, first_name: "user1", last_name: "test1")
      user_visit = create(:user_visit, visit: visit, user: visitor, role: "Other")

      get manager_reserve_visit_user_visits_path(reserve, visit)

      expect(response).to be_ok
      doc = Capybara.string(response.body)
      expect(doc).to have_css("#visitors-summary")
      expect(doc).to have_css("#user-visits-table")
      expect(doc).to have_css("#user_visit_#{user_visit.id}", text: "user1 test1")
      expect(doc).to have_css("#user_visit_#{user_visit.id}",
        text: Manager::Visits::UserVisitPresenter.new(user_visit).date_range)
      expect(doc).to have_css(".add-visitor #add-team-member")
      expect(doc).to have_css(".selected", text: "Add Team Member")
      expect(doc).not_to have_css("#add-guest")
      expect(doc).not_to have_css("#add-group")
    end
  end

  describe "GET /manager/reserves/:reserve_id/visits/:visit_id/reserve_info" do
    it "renders the reserve specific questions" do
      create(:reserve_question, reserve: reserve, location: "visit", question: "Visit question")

      get manager_reserve_visit_reserve_info_index_path(reserve, visit)

      expect(response).to be_ok
      doc = Capybara.string(response.body)
      expect(doc).to have_css(".questions-group", text: "Visit question")
    end

    it "renders the empty message when the reserve has no questions" do
      get manager_reserve_visit_reserve_info_index_path(reserve, visit)

      doc = Capybara.string(response.body)
      expect(doc).to have_css("#no-questions",
        text: "This reserve has no additional questions at this time.")
    end
  end

  describe "GET /manager/reserves/:reserve_id/visits/:visit_id/invoices" do
    it "renders the invoice summary, invoice list and amenity visits" do
      get manager_reserve_visit_invoices_path(reserve, visit)

      expect(response).to be_ok
      doc = Capybara.string(response.body)
      expect(doc).to have_css("table.invoice-totals")
      expect(doc).to have_css(".invoices .invoice-list")
      expect(doc).to have_css(".amenity-visits")
    end
  end
end
