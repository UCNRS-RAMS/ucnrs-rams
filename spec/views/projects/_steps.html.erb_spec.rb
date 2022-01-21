require "rails_helper"

RSpec.describe "app/views/projects/_steps.html.erb", type: :view do
  describe "viewing the steps section" do
    it "has four steps" do
      presenter = ProjectFormPresenter.new(
        user: :fake_user,
        current_step: 2,
      )

      render partial: "projects/steps", locals: { presenter: presenter }

      markup = Capybara.string(rendered)
      expect(markup).to have_css("li", text: "Project Details")
      expect(markup).to have_css("li", text: "Team")
      expect(markup).to have_css("li", text: "Permits")
      expect(markup).to have_css("li", text: "Funding")
    end
  end
end
