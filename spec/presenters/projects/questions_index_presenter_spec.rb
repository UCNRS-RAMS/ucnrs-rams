require "rails_helper"

RSpec.describe Projects::QuestionsIndexPresenter do
  describe "delegations" do
    subject { Projects::QuestionsIndexPresenter.new(current_step: 3, project: build(:project)) }
    it { is_expected.to delegate_method(:svg).to(:steps_presenter) }
    it { is_expected.to delegate_method(:step_class).to(:steps_presenter) }
  end

  describe "#questions_by_reserve" do
    it "groups questions according to reserve name" do
      project = create(:project)
      reserve1 = create(:reserve, name: "Reserve 1")
      reserve2 = create(:reserve, name: "Reserve 2")
      reserve1_question1 = create(:reserve_question, reserve: reserve1)
      reserve1_question2 = create(:reserve_question, reserve: reserve1)
      reserve_1_answer = create(:project_reserve_answer, project: project, reserve_question: reserve1_question1)
      reserve2_question1 = create(:reserve_question, reserve: reserve2)
      reserve_2_answer = create(:project_reserve_answer, project: project, reserve_question: reserve2_question1)
      presenter = Projects::QuestionsIndexPresenter.new(current_step: 3, project: project)

      results = presenter.questions_by_reserve

      expect(results.keys).to eq ["Reserve 1", "Reserve 2"]
      expect(results.values.flatten).to all(be_a(Projects::QuestionPresenter))
      expect(results["Reserve 1"].map(&:id)).to eq [reserve1_question1.id]
      expect(results["Reserve 2"].map(&:id)).to eq [reserve2_question1.id]
    end
  end

  describe "#questions_by_authority" do
    it "groups questions according to the value of the authority field" do
      federal = create(:permit, authority: "Federal", involves_all: true)
      state = create(:permit, authority: "State", involves_all: true)
      local = create(:permit, authority: "Local", involves_all: true)
      institution = create(:permit, authority: "Institution", involves_all: true)
      state2 = create(:permit, authority: "State", involves_all: true, sort_order: 9)
      presenter = Projects::QuestionsIndexPresenter.new(current_step: 3, project: build(:project))

      results = presenter.questions_by_authority

      expect(results.keys).to eq ["federal", "state", "local", "institution"]
      results.values.flatten.each do |value|
        expect(value).to be_a(Projects::PermitPresenter)
      end
      expect(results["federal"].map(&:id)).to eq [federal.id]
      expect(results["state"].map(&:id)).to eq [state.id, state2.id]
      expect(results["local"].map(&:id)).to eq [local.id]
      expect(results["institution"].map(&:id)).to eq [institution.id]
    end

    it "excludes authorities lacking permits" do
      project = build(:project, involves_fish: false)
      federal = create(:permit, authority: "Federal", involves_all: true)
      state = create(:permit, authority: "State", involves_birds: true)
      local = create(:permit, authority: "Local", involves_all: true)
      presenter = Projects::QuestionsIndexPresenter.new(current_step: 3, project: build(:project))

      results = presenter.questions_by_authority

      expect(results.keys).to_not include "institution"
      expect(results.keys).to_not include "state"
    end

    it "includes answers in the results" do
      project = create(:project, involves_fish: false)
      federal = create(:permit, authority: "Federal", involves_all: true)
      answer = create(:project_permit_answer, answer: true, project: project, permit: federal)
      presenter = Projects::QuestionsIndexPresenter.new(current_step: 3, project: project)

      results = presenter.questions_by_authority

      expect(results["federal"].map(&:id)).to eq [federal.id]
      expect(results["federal"][0]).to have_attributes({
        answer: 1,
        answer_id: answer.id,
      })
    end
  end

  describe "#has_permit_questions_for_project?" do
    it "is true if there are permits to be displayed for a project" do
      project = create(:project, involves_mammals: true)
      federal = create(:permit, authority: "Federal", involves_mammals: true)
      presenter = Projects::QuestionsIndexPresenter.new(current_step: 3, project: project)

      expect(presenter).to have_permit_questions_for_project
    end

    it "is false if there are no questions to be displayed for a project" do
      project = create(:project, involves_mammals: false)
      presenter = Projects::QuestionsIndexPresenter.new(current_step: 3, project: project)

      expect(presenter).not_to have_permit_questions_for_project
    end
  end

  describe "#has_reserve_questions_for_project?" do
    it "is true if there are permits to be displayed for a project" do
      project = create(:project, involves_mammals: true)
      answer = create(:project_reserve_answer, project: project)
      presenter = Projects::QuestionsIndexPresenter.new(current_step: 3, project: project)

      expect(presenter).to have_reserve_questions_for_project
    end

    it "is false if there are no questions to be displayed for a project" do
      project = create(:project, involves_mammals: false)
      presenter = Projects::QuestionsIndexPresenter.new(current_step: 3, project: project)

      expect(presenter).not_to have_reserve_questions_for_project
    end
  end
end
