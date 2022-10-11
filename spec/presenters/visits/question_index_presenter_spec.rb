require "rails_helper"
RSpec.describe Visits::QuestionsIndexPresenter do
  describe "delegations" do
    subject { Visits::QuestionsIndexPresenter.new(current_step: 3, visit: build(:visit)) }
    it { is_expected.to delegate_method(:svg).to(:steps_presenter) }
    it { is_expected.to delegate_method(:step_class).to(:steps_presenter) }
  end

  describe "#reserve_questions_by_authority" do
    it "groups questions according to authority" do
      reserve1 = create(:reserve, name: "Reserve 1")
      visit = create(:visit, reserve_id: reserve1.id)
      create(:reserve_question, reserve_id: reserve1.id, authority: "Federal")
      create(:reserve_question, reserve_id: reserve1.id, authority: "State")
      presenter = Visits::QuestionsIndexPresenter.new(current_step: 3, visit: visit)

      results = presenter.reserve_questions_by_authority
      expect(results.keys).to eq %w[federal state]
    end
  end

  describe "#permit_questions_by_authority" do
    it "groups questions according to the value of the authority field" do
      federal = create(:permit, authority: "Federal", involves_all: true, location: "visit")
      state = create(:permit, authority: "State", involves_all: true, location: "visit")
      local = create(:permit, authority: "Local", involves_all: true, location: "visit")
      institution = create(:permit, authority: "Institution", involves_all: true, location: "visit")
      state2 = create(:permit, authority: "State", involves_all: true, sort_order: 9, location: "visit")
      presenter = Visits::QuestionsIndexPresenter.new(current_step: 3, visit: build(:visit))

      results = presenter.permit_questions_by_authority

      expect(results.keys).to eq [["federal", "visit"], ["state", "visit"], ["local", "visit"], ["institution", "visit"]]
      results.values.flatten.each do |value|
        expect(value).to be_a(Visits::PermitPresenter)
      end
      expect(results[["federal", "visit"]].map(&:id)).to eq [federal.id]
      expect(results[["state", "visit"]].map(&:id)).to eq [state.id, state2.id]
      expect(results[["local", "visit"]].map(&:id)).to eq [local.id]
      expect(results[["institution", "visit"]].map(&:id)).to eq [institution.id]
    end

    it "excludes authorities lacking permits" do
      create(:permit, authority: "Federal", involves_all: true, location: "visit")
      create(:permit, authority: "State", involves_birds: true, location: "visit")
      create(:permit, authority: "Local", involves_all: true, location: "visit")
      presenter = Visits::QuestionsIndexPresenter.new(current_step: 3, visit: build(:visit))

      results = presenter.permit_questions_by_authority

      expect(results.keys).to_not include "institution"
      expect(results.keys).to_not include "state"
    end
  end

  describe "#has_permit_questions_for_visit?" do
    it "is true if there are permits to be displayed for a visit" do
      project = create(:project, involves_mammals: true)
      visit = create(:visit, visit, project_id: project.id)
      create(:permit, authority: "Federal", involves_mammals: true, location: "visit")
      presenter = Visits::QuestionsIndexPresenter.new(current_step: 3, visit: visit)

      expect(presenter).to have_permit_questions_for_project
    end

    it "is false if there are no questions to be displayed for a visit" do
      project = create(:project, involves_mammals: false)
      visit = create(:visit, visit, project_id: project.id)
      presenter = Visits::QuestionsIndexPresenter.new(current_step: 3, visit: visit)

      expect(presenter).not_to have_permit_questions_for_project
    end
  end

  describe "#has_reserve_questions_for_visit?" do
    it "is true if there are reserve_questions to be displayed for a visit" do
      reserve = create(:reserve)
      visit = create(:visit, reserve_id: reserve.id)
      reserve_question = create(:reserve_question, reserve: reserve, location: "visit")
      create(:visit_reserve_answer, reserve_question_id: reserve_question.id, visit_id: visit.id)
      presenter = Visits::QuestionsIndexPresenter.new(current_step: 3, visit: visit)
      expect(presenter).to have_reserve_questions_for_visit
    end

    it "is false if there are no questions to be displayed for a visit" do
      visit = create(:visit)
      presenter = Visits::QuestionsIndexPresenter.new(current_step: 3, visit: visit)

      expect(presenter).not_to have_reserve_questions_for_visit
    end
  end

  describe "#form_url" do
    it "it returns permit url to visit namespace" do
      visit = create(:visit)
      presenter = Visits::QuestionsIndexPresenter.new(visit: visit, current_step: 2)

      expect(presenter.form_url).to eq("/visits/#{visit.id}/answers")
    end
  end
end
