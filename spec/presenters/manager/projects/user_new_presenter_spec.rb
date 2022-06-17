require "rails_helper"

RSpec.describe Manager::Projects::UserNewPresenter do
  describe "#user_form_path" do
    it "returns the path for project users" do
      project = create(:project)
      presenter = Manager::Projects::UserNewPresenter.new(
        form: :fake_form,
        project: project,
      )

      expected_value = "/manager/reserves/#{project.reserve_id}/projects/#{project.id}/users"
      expect(presenter.user_form_path).to eq expected_value
    end
  end
end
