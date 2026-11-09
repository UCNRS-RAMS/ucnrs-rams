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
        project = create(:project, status: :incomplete, members: [create(:user)])
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

    describe "reserves selected for contact" do
      it "saves the selected reserves as the project's interests" do
        project = create(:project, status: :open)
        reserve_one = create(:reserve)
        reserve_two = create(:reserve)
        form = ProjectCompleteForm.new(params: { id: project.id, reserve_ids: [reserve_one.id.to_s, reserve_two.id.to_s] })

        form.save

        expect(project.reserve_interests.map(&:reserve)).to contain_exactly(reserve_one, reserve_two)
      end

      it "removes reserves that are no longer selected" do
        project = create(:project, status: :open)
        kept_reserve = create(:reserve)
        removed_reserve = create(:reserve)
        create(:project_reserve_interest, project: project, reserve: kept_reserve)
        create(:project_reserve_interest, project: project, reserve: removed_reserve)
        form = ProjectCompleteForm.new(params: { id: project.id, reserve_ids: [kept_reserve.id.to_s] })

        form.save

        expect(project.reserve_interests.map(&:reserve)).to contain_exactly(kept_reserve)
      end

      it "does not save the selection when the project cannot be saved" do
        project = build(:project, status: :incomplete, title: nil)
        project.save(validate: false)
        reserve = create(:reserve)
        form = ProjectCompleteForm.new(params: { id: project.id, reserve_ids: [reserve.id.to_s] })

        expect(form.save).to be false
        expect(project.reserve_interests.map(&:reserve)).to be_empty
      end

      it "keeps reserves selected after the first submission" do
        project = create(:project, status: :open)
        reserve = create(:reserve)
        form = ProjectCompleteForm.new(params: { id: project.id, reserve_ids: [reserve.id.to_s] })

        form.save

        expect(project.reserve_interests.map(&:reserve)).to contain_exactly(reserve)
      end
    end

    describe "#first_submission?" do
      it "is true when an incomplete project is saved" do
        project = create(:project, status: :incomplete, members: [create(:user)])
        form = ProjectCompleteForm.new(params: { id: project.id })

        form.save

        expect(form).to be_first_submission
      end

      it "is false when the project was already submitted" do
        project = create(:project, status: :open)
        form = ProjectCompleteForm.new(params: { id: project.id })

        form.save

        expect(form).not_to be_first_submission
      end
    end
  end
end
