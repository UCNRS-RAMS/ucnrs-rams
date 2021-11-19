require "rails_helper"

RSpec.describe ProjectsNewPresenter do
  describe "delegations" do
    subject { ProjectsNewPresenter.new(user: :dummy, current_step: 1) }
    it { is_expected.to delegate_method(:svg).to(:steps_presenter) }
    it { is_expected.to delegate_method(:step_class).to(:steps_presenter) }
  end

  describe "#partial_name" do
    it "generates the name of the partial to render from project_type" do
      presenter = ProjectsNewPresenter.new(
        user: :dummy,
        current_step: 1,
        project_type: :meeting_or_conference
      )

      expect(presenter.partial_name).to eq "projects/meeting_or_conference_form"
    end
  end

  describe "#project_type_options" do
    it "lists the types of projects" do
      presenter = ProjectsNewPresenter.new(user: :dummy, current_step: 1)

      expect(presenter.project_type_options).to eq [
        :research,
        :university_class,
        :meeting_or_conference,
      ]
    end
  end
end
