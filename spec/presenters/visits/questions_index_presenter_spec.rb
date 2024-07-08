require "rails_helper"
RSpec.describe Visits::QuestionsIndexPresenter do
  describe "delegations" do
    subject { Visits::QuestionsIndexPresenter.new(current_step: 3, visit: build(:visit)) }
    it { is_expected.to delegate_method(:svg).to(:steps_presenter) }
    it { is_expected.to delegate_method(:step_class).to(:steps_presenter) }
  end

  describe "#reserve_questions_by_location" do
    it "returns reserve questions wrapped in Visits::QuestionPresenter" do
      reserve = create(:reserve)
      visit = create(:visit, reserve: reserve)
      question1 = create(:reserve_question, reserve: reserve, location: :visit)
      question2 = create(:reserve_question, reserve: reserve, location: :project)
      presenter = Visits::QuestionsIndexPresenter.new(current_step: 3, visit: visit)

      results = presenter.reserve_questions_by_location

      expect(results.values.flatten.map(&:id))
        .to match_array [question1.id, question2.id]
      expect(results.values.flatten).to all(be_instance_of Visits::QuestionPresenter)
    end

    it "returns reserve questions in order" do
      reserve = create(:reserve)
      visit = create(:visit, reserve: reserve)
      question1 = create(:reserve_question, reserve: reserve, location: :visit, sort_order: 2)
      question2 = create(:reserve_question, reserve: reserve, location: :visit, sort_order: 1)
      question3 = create(:reserve_question, reserve: reserve, location: :visit, sort_order: 3)
      presenter = Visits::QuestionsIndexPresenter.new(current_step: 3, visit: visit)

      results = presenter.reserve_questions_by_location

      expect(results.values.flatten.map(&:id)).to eq [question2.id, question1.id, question3.id]
    end

    context "if visit has not been submitted and answers do not exist" do
      it "return questions from reserve questions table" do
        reserve = create(:reserve)
        visit = create(:visit, reserve: reserve, submitted_at: nil)
        visit_question1 = create(:reserve_question, location: :visit)
        visit_question2 = create(:reserve_question, reserve: reserve, location: :visit)
        project_question1 = create(:reserve_question, reserve: reserve, location: :project)
        project_question2 = create(:reserve_question, location: :project)
        presenter = Visits::QuestionsIndexPresenter.new(current_step: 3, visit: visit)

        results = presenter.reserve_questions_by_location

        expect(results.keys).to match_array %w[visit project]
        expect(results["visit"].map(&:id)).to match_array [visit_question2.id]
        expect(results["project"].map(&:id)).to match_array [project_question1.id]
      end

      it "returns only visible reserve questions" do
        reserve = create(:reserve)
        visit = create(:visit, reserve: reserve)
        question1 = create(:reserve_question, reserve: reserve, location: :visit, visible: true)
        question2 = create(:reserve_question, reserve: reserve, location: :visit, visible: false)
        question3 = create(:reserve_question, reserve: reserve, location: :visit, visible: true)
        presenter = Visits::QuestionsIndexPresenter.new(current_step: 3, visit: visit)

        results = presenter.reserve_questions_by_location

        expect(results.values.flatten.map(&:id)).to eq [question1.id, question3.id]
      end
    end

    context "if visit has not been submitted and visit answer exist" do
      it "return questions from project answer and visit answer table " do
        reserve = create(:reserve)
        visit = create(:visit, reserve: reserve, submitted_at: nil)
        visit_question1 = create(:reserve_question, location: :visit)
        visit_question2 = create(:reserve_question, reserve: reserve, location: :visit)
        project_question1 = create(:reserve_question, reserve: reserve, location: :project)
        project_question2 = create(:reserve_question, location: :project)
        visit_answer2 = create(:visit_reserve_answer, visit: visit, reserve_question: visit_question2)
        project_answer1 = create(:project_reserve_answer, project: visit.project, reserve_question: project_question1)
        presenter = Visits::QuestionsIndexPresenter.new(current_step: 3, visit: visit)

        results = presenter.reserve_questions_by_location

        expect(results.keys).to match_array %w[visit project]
        expect(results["visit"].map(&:id)).to match_array [visit_question2.id]
        expect(results["project"].map(&:id)).to match_array [project_question1.id]
      end
    end



    context "if visit is submitted" do
      it "locates questions only from visit answer table" do
        reserve = create(:reserve)
        visit = create(:visit, reserve: reserve, submitted_at: Time.current)
        visit_question1 = create(:reserve_question, reserve: reserve, location: :visit)
        visit_question2 = create(:reserve_question, reserve: reserve, location: :visit)
        project_question1 = create(:reserve_question, reserve: reserve, location: :project)
        visit_answer1 = create(:visit_reserve_answer, visit: visit, reserve_question: visit_question1)
        project_answer1 = create(:project_reserve_answer, project: visit.project, reserve_question: project_question1)
        presenter = Visits::QuestionsIndexPresenter.new(current_step: 3, visit: visit)

        results = presenter.reserve_questions_by_location

        expect(results.keys).to match_array %w[visit]
        expect(results["visit"].map(&:id)).to match_array [visit_question1.id]
      end
    end

    it "groups questions according to location" do
      reserve = create(:reserve)
      visit = create(:visit, reserve: reserve)
      create(:reserve_question, reserve: reserve, location: :visit)
      create(:reserve_question, reserve: reserve, location: :project)
      presenter = Visits::QuestionsIndexPresenter.new(current_step: 3, visit: visit)

      results = presenter.reserve_questions_by_location

      expect(results.keys).to match_array %w[visit project]
    end
  end

  describe "#permit_questions_by_authority" do
    it "shows permit questions in order" do
      permit1 = create(:permit, involves_all: true, location: :visit, sort_order: 3)
      permit2 = create(:permit, involves_all: true, location: :visit, sort_order: 1)
      permit3 = create(:permit, involves_all: true, location: :visit, sort_order: 2)
      presenter = Visits::QuestionsIndexPresenter.new(current_step: 3, visit: build(:visit))

      results = presenter.permit_questions_by_authority

      expect(results.keys).to eq [[permit2.authority, "visit"]]
      expect(results[[permit2.authority, "visit"]].map(&:id)).to eq [permit2.id, permit3.id, permit1.id]
    end

    it "only shows permit questions that are visible" do
      permit1 = create(:permit, involves_all: true, location: :visit, visible: false)
      permit2 = create(:permit, involves_all: true, location: :visit, visible: true)
      presenter = Visits::QuestionsIndexPresenter.new(current_step: 3, visit: build(:visit))

      results = presenter.permit_questions_by_authority

      expect(results.keys).to eq [[permit2.authority, "visit"]]
      expect(results[[permit2.authority, "visit"]].map(&:id)).to eq [permit2.id]
    end

    it "returns permit questions wrapped in Visits::PermitPresenter" do
      permit1 = create(:permit, involves_all: true, location: :visit)
      permit2 = create(:permit, involves_all: true, location: :visit)
      permit3 = create(:permit, involves_all: true, location: :visit)
      presenter = Visits::QuestionsIndexPresenter.new(current_step: 3, visit: build(:visit))

      permit_questions_by_authority = presenter.permit_questions_by_authority

      expect(permit_questions_by_authority.values.flatten.map(&:id))
        .to match_array [permit1.id, permit2.id, permit3.id]
      expect(permit_questions_by_authority.values.flatten).to all(be_instance_of Visits::PermitPresenter)
    end

    it "returns only visit permits" do
      permit1 = create(:permit, involves_all: true, location: :visit)
      permit2 = create(:permit, involves_all: true, location: :project)
      permit3 = create(:permit, involves_all: true, location: :visit)
      presenter = Visits::QuestionsIndexPresenter.new(current_step: 3, visit: build(:visit))

      permit_questions_by_authority = presenter.permit_questions_by_authority

      expect(permit_questions_by_authority.values.flatten.map(&:id))
        .to match_array [permit1.id, permit3.id]
    end

    it "returns only visit permits questions with watching visit project_type" do
      project = create(:project, project_type: :class)
      visit = create(:visit, project: project)
      permit1 = create(:permit, involves_all: true, location: :visit, university_class: true)
      permit2 = create(:permit, involves_all: true, location: :visit, research: true)
      permit3 = create(:permit, involves_all: true, location: :visit, public: true)
      permit4 = create(:permit, involves_all: true, location: :visit, university_class: true)
      presenter = Visits::QuestionsIndexPresenter.new(current_step: 3, visit: visit)

      permit_questions_by_authority = presenter.permit_questions_by_authority

      expect(permit_questions_by_authority.values.flatten.map(&:id))
        .to match_array [permit1.id, permit4.id]
    end

    it "returns only visit permits questions with watching 'involves'" do
      project = create(:project, involves_fish: true, involves_birds: false,
        involves_reptiles: true, involves_amphibians: true)
      visit = create(:visit, project: project)
      permit1 = create(:permit, involves_fish: true, location: :visit)
      permit2 = create(:permit, involves_birds: true, location: :visit)
      permit3 = create(:permit, involves_reptiles: true, location: :visit)
      permit4 = create(:permit, involves_amphibians: false, location: :visit)
      presenter = Visits::QuestionsIndexPresenter.new(current_step: 3, visit: visit)

      permit_questions_by_authority = presenter.permit_questions_by_authority

      expect(permit_questions_by_authority.values.flatten.map(&:id))
        .to match_array [permit1.id, permit3.id]
    end

    it "groups questions according to the value of the authority field" do
      federal = create(:permit, authority: "Federal", involves_all: true, location: :visit)
      state = create(:permit, authority: "State", involves_all: true, location: :visit)
      local = create(:permit, authority: "Local", involves_all: true, location: :visit)
      institution = create(:permit, authority: "Institution", involves_all: true, location: :visit)
      state2 = create(:permit, authority: "State", involves_all: true, sort_order: 9, location: :visit)
      presenter = Visits::QuestionsIndexPresenter.new(current_step: 3, visit: build(:visit))

      results = presenter.permit_questions_by_authority

      expect(results.keys).to eq [["federal", "visit"], ["state", "visit"], ["local", "visit"], ["institution", "visit"]]
      expect(results[["federal", "visit"]].map(&:id)).to eq [federal.id]
      expect(results[["state", "visit"]].map(&:id)).to eq [state.id, state2.id]
      expect(results[["local", "visit"]].map(&:id)).to eq [local.id]
      expect(results[["institution", "visit"]].map(&:id)).to eq [institution.id]
    end

    it "excludes authorities lacking permits" do
      create(:permit, authority: "Federal", involves_all: true, location: :visit)
      create(:permit, authority: "State", involves_birds: true, location: :visit)
      create(:permit, authority: "Local", involves_all: true, location: :visit)
      presenter = Visits::QuestionsIndexPresenter.new(current_step: 3, visit: build(:visit))

      results = presenter.permit_questions_by_authority

      expect(results.keys).to_not include "institution"
      expect(results.keys).to_not include "state"
    end
  end

  describe "#has_permit_questions_for_visit?" do
    it "is true if there are permits to be displayed for a visit" do
      project = create(:project, involves_mammals: true)
      visit = create(:visit, project: project)
      create(:permit, authority: "Federal", involves_mammals: true, location: :visit)

      presenter = Visits::QuestionsIndexPresenter.new(current_step: 3, visit: visit)

      expect(presenter).to have_permit_questions_for_project
    end

    it "is false if there are no questions to be displayed for a visit" do
      project = create(:project, involves_mammals: false)
      visit = create(:visit, project: project)

      presenter = Visits::QuestionsIndexPresenter.new(current_step: 3, visit: visit)

      expect(presenter).not_to have_permit_questions_for_project
    end
  end

  describe "#has_reserve_questions_for_visit?" do
    it "is true if there are reserve_questions to be displayed for a visit" do
      reserve = create(:reserve)
      visit = create(:visit, reserve: reserve)
      reserve_question = create(:reserve_question, reserve: reserve, location: :visit)
      create(:visit_reserve_answer, reserve_question: reserve_question, visit: visit)

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

      presenter = Visits::QuestionsIndexPresenter.new(visit: visit, current_step: 3)

      expect(presenter.form_url).to eq("/visits/#{visit.id}/answers")
    end
  end

  describe "#save_btn_partial_path" do
    it "returns the path to the save_button partial" do
      visit = create(:visit)

      presenter = Visits::QuestionsIndexPresenter.new(visit: visit, current_step: 3)

      expect(presenter.save_btn_partial_path).to eq("visits/questions/save_btn")
    end
  end
end
