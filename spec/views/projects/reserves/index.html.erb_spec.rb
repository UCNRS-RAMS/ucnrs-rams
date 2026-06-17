require "rails_helper"

RSpec.describe "app/views/projects/reserves/index.html.erb" do
  describe "on any render" do
    it "includes steps (on step 5)" do
      project = build_stubbed(:project)
      assign(:presenter, Projects::ReservesIndexPresenter.new(
        project: project,
        current_step: 5,
      ))

      render template: "projects/reserves/index"

      doc = Capybara.string(rendered)
      expect(doc).to have_css("section.progress-steps")
      expect(doc).to have_css(".progress-steps li.active:nth-child(5)")
    end

    it "renders a form posting to the complete endpoint" do
      project = create(:project)
      assign(:presenter, Projects::ReservesIndexPresenter.new(
        current_step: 5,
        project: project,
      ))

      render template: "projects/reserves/index"

      doc = Capybara.string(rendered)
      expect(doc).to have_css(
        "form#reserves-selection[action='/projects/#{project.id}/complete']"
      )
    end

    it "renders a submit button that targets the reserves form" do
      project = create(:project)
      assign(:presenter, Projects::ReservesIndexPresenter.new(
        current_step: 5,
        project: project,
      ))

      render template: "projects/reserves/index"

      doc = Capybara.string(rendered)
      expect(doc).to have_css(
        ".controls button[form='reserves-selection']",
        text: "Save Project & Submit",
      )
    end

    it "renders a checkbox for every reserve" do
      project = build_stubbed(:project)
      reserve_one = build_stubbed(:reserve, name: "Alpha Reserve")
      reserve_two = build_stubbed(:reserve, name: "Beta Reserve")
      allow(Reserve).to receive(:alphabetized).and_return([reserve_one, reserve_two])
      assign(:presenter, Projects::ReservesIndexPresenter.new(
        current_step: 5,
        project: project,
      ))

      render template: "projects/reserves/index"

      doc = Capybara.string(rendered)
      expect(doc).to have_field(
        "Alpha Reserve",
        type: "checkbox",
        with: reserve_one.id.to_s,
      )
      expect(doc).to have_field(
        "Beta Reserve",
        type: "checkbox",
        with: reserve_two.id.to_s,
      )
      expect(doc).to have_css(
        "form#reserves-selection input[type='checkbox'][name='project[reserve_ids][]']",
        count: 2,
      )
    end

    it "renders a link to go back to the previous step (funding)" do
      project = build_stubbed(:project)
      assign(:presenter, Projects::ReservesIndexPresenter.new(
        current_step: 5,
        project: project,
      ))

      render template: "projects/reserves/index"

      doc = Capybara.string(rendered)
      expect(doc).to have_css(".controls a[href='/projects/#{project.id}/fundings']", text: "Go Back")
    end
  end
end
