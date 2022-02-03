require "rails_helper"

RSpec.describe "show.html.erb" do
  describe "on any render" do
    it "includes sidebar" do
      visit = create(:visit, status: "in_review")
      assign(:presenter, VisitShowPresenter.new(visit))

      render template: "visits/show"

      doc = Capybara.string(rendered)

      expect(doc).to have_css("section.sidebar")
    end

    it "includes content top" do
      visit = create(:visit, status: "in_review")
      assign(:presenter, VisitShowPresenter.new(visit))

      render template: "visits/show"

      doc = Capybara.string(rendered)

      expect(doc).to have_css("section.content")
      expect(doc).to have_css("table.visit-summary-table")
      expect(doc).to have_css("a", text: "Edit Visit")
    end
  end

  describe "based on visit status" do
    context "when status is in_review" do
      it "display in_review sidebar" do
        visit = create(:visit, status: "in_review")
        assign(:presenter, VisitShowPresenter.new(visit))

        render template: "visits/show"

        doc = Capybara.string(rendered)

        expect(doc).to have_css("header.in_review")
      end
    end

    context "when status is approved" do
      it "display approved sidebar" do
        visit = create(:visit, status: "approved")
        assign(:presenter, VisitShowPresenter.new(visit))

        render template: "visits/show"

        doc = Capybara.string(rendered)

        expect(doc).to have_css("header.approved")
      end
    end

    context "when status is cancelled" do
      it "display cancelled sidebar" do
        visit = create(:visit, status: "cancelled")
        assign(:presenter, VisitShowPresenter.new(visit))

        render template: "visits/show"

        doc = Capybara.string(rendered)

        expect(doc).to have_css("header.cancelled")
      end
    end

    context "when status is denied" do
      it "display denied sidebar" do
        visit = create(:visit, status: "denied")
        assign(:presenter, VisitShowPresenter.new(visit))

        render template: "visits/show"

        doc = Capybara.string(rendered)

        expect(doc).to have_css("header.denied")
      end
    end
  end
end
