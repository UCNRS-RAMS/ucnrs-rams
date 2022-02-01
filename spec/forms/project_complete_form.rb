require "rails_helper"

RSpec.describe ProjectCompleteForm, type: :model do
  describe "initialization" do
    it "finds a project from an id in params" do
      project = create(:project)
      form = ProjectCompleteForm.new(params: { id: project.id })

      expect(form.project).to eq project
    end
  end

  describe "#save" do
    describe "a project with a status of 'incomplete'" do
      it "updates the project's status to 'open'" do
        project = create(:project, status: :incomplete)
        form = ProjectCompleteForm.new(params: { id: project.id })

        form.save

        expect(project.reload).to be_open
      end
    end

    describe "a project with a status of something other 'incomplete'" do
      it "does not update the project's status" do
        project = create(:project, status: :closed)
        form = ProjectCompleteForm.new(params: { id: project.id })

        form.save

        expect(project.reload).to be_closed
      end
    end
  end
end
