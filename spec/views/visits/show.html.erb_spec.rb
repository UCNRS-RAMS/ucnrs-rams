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

    it "includes content" do
      visit = create(:visit, status: "in_review")
      assign(:presenter, VisitShowPresenter.new(visit))

      render template: "visits/show"

      doc = Capybara.string(rendered)

      expect(doc).to have_css("section.content")
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

      it "display in_review content" do
        visit = create(:visit, status: "in_review")
        assign(:presenter, VisitShowPresenter.new(visit))

        render template: "visits/show"

        doc = Capybara.string(rendered)

        expect(doc).to have_css("section.visit-summary")
        expect(doc).to have_css("section.visit-visitors")
        expect(doc).to have_css("section.visit-amenities")
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

      it "display approved content" do
        visit = create(:visit, status: "approved")
        assign(:presenter, VisitShowPresenter.new(visit))

        render template: "visits/show"

        doc = Capybara.string(rendered)

        expect(doc).to have_css("section.visit-waivers")
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

      it "display cancelled content" do
        visit = create(:visit, status: "cancelled")
        assign(:presenter, VisitShowPresenter.new(visit))

        render template: "visits/show"

        doc = Capybara.string(rendered)

        expect(doc).to have_css("section.visit-summary")
        expect(doc).to have_css("section.visit-visitors")
        expect(doc).to have_css("section.visit-amenities")
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

      it "display denied content" do
        visit = create(:visit, status: "denied")
        assign(:presenter, VisitShowPresenter.new(visit))

        render template: "visits/show"

        doc = Capybara.string(rendered)

        expect(doc).to have_css("section.visit-summary")
        expect(doc).to have_css("section.visit-visitors")
        expect(doc).to have_css("section.visit-amenities")
      end
    end
  end
end
