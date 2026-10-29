require "rails_helper"
RSpec.describe Visits::QuestionsIndexPresenter do
  describe "delegations" do
    subject { Visits::QuestionsIndexPresenter.new(current_step: 3, visit: build(:visit)) }
    it { is_expected.to delegate_method(:svg).to(:steps_presenter) }
    it { is_expected.to delegate_method(:step_class).to(:steps_presenter) }
  end

  describe "#reserve_questions_by_location" do
    subject(:results) { presenter.reserve_questions_by_location }

    let(:presenter) { described_class.new(current_step: 3, visit: visit) }
    let(:reserve) { create(:reserve) }
    let(:project) { create(:project) }
    let(:visit) { create(:visit, reserve: reserve, project: project) }

    context "when the visit is submitted" do
      let(:visit) { create(:visit, reserve: reserve, project: project, submitted_at: Time.current) }
      let!(:earlier_visit) { create(:visit, reserve: reserve, project: project, submitted_at: Time.current) }
      let!(:visit_question) do
        create(:reserve_question, reserve: reserve, location: :visit, question_type: :text)
      end
      let!(:other_visit_question) do
        create(:reserve_question, reserve: reserve, location: :visit, question_type: :text)
      end
      let!(:project_question) do
        create(:reserve_question, reserve: reserve, location: :project, question_type: :text)
      end

      before do
        create(:visit_reserve_answer, visit: earlier_visit, reserve_question: visit_question,
          text_answer: "earlier visit")
        create(:project_reserve_answer, project: project, reserve_question: project_question,
          text_answer: "project answer")
      end

      it "returns only the visit questions this visit answered, without project questions" do
        create(:visit_reserve_answer, visit: visit, reserve_question: visit_question,
          text_answer: "visit answer")
        create(:visit_reserve_answer, visit: visit, reserve_question: other_visit_question,
          text_answer: "other visit answer")

        expect(results.keys).to match_array %w[visit]
        expect(results["visit"].map(&:id)).to match_array [visit_question.id, other_visit_question.id]
        expect(results["visit"].map(&:text_answer)).to match_array ["visit answer", "other visit answer"]
      end

      it "omits visit questions this visit did not answer" do
        create(:visit_reserve_answer, visit: visit, reserve_question: visit_question,
          text_answer: "visit answer")

        expect(results["visit"].map(&:id)).to eq [visit_question.id]
      end
    end

    context "on a first visit to the reserve" do
      context "before any answers are saved" do
        it "returns the reserve's visit and project questions wrapped in Visits::QuestionPresenter" do
          visit_question = create(:reserve_question, reserve: reserve, location: :visit)
          project_question = create(:reserve_question, reserve: reserve, location: :project)

          expect(results.keys).to match_array %w[visit project]
          expect(results.values.flatten.map(&:id)).to match_array [visit_question.id, project_question.id]
          expect(results.values.flatten).to all(be_instance_of Visits::QuestionPresenter)
        end

        it "returns reserve questions in order" do
          question2 = create(:reserve_question, reserve: reserve, location: :visit, sort_order: 2)
          question1 = create(:reserve_question, reserve: reserve, location: :visit, sort_order: 1)
          question3 = create(:reserve_question, reserve: reserve, location: :visit, sort_order: 3)

          expect(results["visit"].map(&:id)).to eq [question1.id, question2.id, question3.id]
        end

        it "returns only visible reserve questions" do
          question1 = create(:reserve_question, reserve: reserve, location: :visit, visible: true)
          create(:reserve_question, reserve: reserve, location: :visit, visible: false)
          question3 = create(:reserve_question, reserve: reserve, location: :visit, visible: true)

          expect(results["visit"].map(&:id)).to eq [question1.id, question3.id]
        end

        context "when the project involves mammals" do
          let(:project) { create(:project, involves_none: false, involves_mammals: true) }

          it "returns only reserve questions involving what the project involves" do
            ignoring_question = create(:reserve_question, reserve: reserve, location: :visit,
              ignore_involvements: true)
            mammals_question = create(:reserve_question, reserve: reserve, location: :visit,
              ignore_involvements: false, involves_mammals: true)
            create(:reserve_question, reserve: reserve, location: :visit,
              ignore_involvements: false, involves_fish: true)

            expect(results["visit"].map(&:id)).to match_array [ignoring_question.id, mammals_question.id]
          end
        end
      end

      context "with saved answers" do
        it "returns the answered visit and project questions" do
          visit_question = create(:reserve_question, reserve: reserve, location: :visit, question_type: :text)
          project_question = create(:reserve_question, reserve: reserve, location: :project,
            question_type: :text)
          create(:visit_reserve_answer, visit: visit, reserve_question: visit_question,
            text_answer: "visit answer")
          create(:project_reserve_answer, project: project, reserve_question: project_question,
            text_answer: "project answer")

          expect(results.keys).to match_array %w[visit project]
          expect(results["visit"].map(&:text_answer)).to match_array ["visit answer"]
          expect(results["project"].map(&:text_answer)).to match_array ["project answer"]
        end

        it "omits an unanswered visit question when a project answer exists for this reserve" do
          project_question = create(:reserve_question, reserve: reserve, location: :project)
          visit_question = create(:reserve_question, reserve: reserve, location: :visit, answer_required: true)
          create(:project_reserve_answer, project: project, reserve_question: project_question)

          expect(results.keys).to match_array %w[project]
          expect(results["project"].map(&:id)).to match_array [project_question.id]
          expect(results.values.flatten.map(&:id)).not_to include(visit_question.id)
        end
      end

      context "when the project already answered at another reserve" do
        let!(:other_reserve_visit) { create(:visit, submitted_at: Time.current) }
        let(:visit) { create(:visit, reserve: reserve, project: other_reserve_visit.project) }

        before do
          other_reserve_question = create(
            :reserve_question,
            reserve: other_reserve_visit.reserve,
            location: :project,
          )
          create(:project_reserve_answer, project: other_reserve_visit.project,
            reserve_question: other_reserve_question)
        end

        it "still returns this reserve's visit and project questions" do
          visit_question = create(:reserve_question, reserve: reserve, location: :visit)
          project_question = create(:reserve_question, reserve: reserve, location: :project)

          expect(results["visit"].map(&:id)).to match_array [visit_question.id]
          expect(results["project"].map(&:id)).to match_array [project_question.id]
        end
      end
    end

    context "on a later visit to the reserve" do
      let!(:earlier_visit) { create(:visit, reserve: reserve, project: project, submitted_at: Time.current) }

      it "returns the reserve's visit-level questions before any answers are saved" do
        visit_question = create(:reserve_question, reserve: reserve, location: :visit)
        create(:reserve_question, reserve: reserve, location: :project)
        create(:visit_reserve_answer, visit: earlier_visit, reserve_question: visit_question)

        expect(results.keys).to match_array %w[visit]
        expect(results["visit"].map(&:id)).to match_array [visit_question.id]
      end

      context "with saved answers" do
        it "returns only the visit questions this visit answered, without project questions" do
          visit_question = create(:reserve_question, reserve: reserve, location: :visit, question_type: :text)
          other_visit_question = create(:reserve_question, reserve: reserve, location: :visit,
            question_type: :text)
          project_question = create(:reserve_question, reserve: reserve, location: :project,
            question_type: :text)
          create(:visit_reserve_answer, visit: visit, reserve_question: visit_question,
            text_answer: "visit answer")
          create(:visit_reserve_answer, visit: earlier_visit, reserve_question: other_visit_question,
            text_answer: "earlier visit")
          create(:project_reserve_answer, project: project, reserve_question: project_question,
            text_answer: "project answer")

          expect(results.keys).to match_array %w[visit]
          expect(results["visit"].map(&:id)).to eq [visit_question.id]
          expect(results["visit"].map(&:text_answer)).to match_array ["visit answer"]
        end
      end
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
