require "rails_helper"

RSpec.describe "app/views/projects/questions/index.html.erb" do
  describe "on any render" do
    it "includes steps (on step 3)" do
      assign(:presenter, Projects::QuestionsIndexPresenter.new(
        project: build_stubbed(:project),
        current_step: 3,
      ))

      render template: "projects/questions/index"

      doc = Capybara.string(rendered)
      expect(doc).to have_css("section.progress-steps")
      expect(doc).to have_css(".progress-steps li.active:nth-child(3)")
    end

    it "displays a message in an empty form if there are no questions to show" do
      _unapplicable_permit = build(:permit, involves_mammals: false)
      assign(:presenter, Projects::QuestionsIndexPresenter.new(
        project: build_stubbed(:project, involves_mammals: true),
        current_step: 3,
      ))

      render template: "projects/questions/index"

      doc = Capybara.string(rendered)
      expect(doc).to have_content("There are no necessary permit questions for this project at this time.")
      expect(doc).to have_css("form#questions")
      expect(doc).to have_no_css("form#questions input")
    end

    describe "the submit button" do
      it "renders a button with the correct text for step 3" do
        assign(:presenter, Projects::QuestionsIndexPresenter.new(
          project: build_stubbed(:project),
          current_step: 3,
        ))

        render template: "projects/questions/index"

        doc = Capybara.string(rendered)
        expect(doc).to have_css("button[form='questions']", text: "Next: Funding")
      end
    end

    it "renders a link to go back to the previous step (team members)" do
      project = build_stubbed(:project)
      assign(:presenter, Projects::QuestionsIndexPresenter.new(
        current_step: 3,
        project: project,
      ))

      render template: "projects/questions/index"

      doc = Capybara.string(rendered)
      expect(doc).to have_css(".controls a[href='/projects/#{project.id}/team_memberships']", text: "Go Back")
    end
  end

  describe "when there are permit questions to show" do
    it "has an authority section for each authority" do
      project = build_stubbed(:project)
      federal = create(:permit, authority: :federal, involves_all: true)
      state = create(:permit, authority: :state, involves_all: true)
      local = create(:permit, authority: :local, involves_all: true)
      institution = create(:permit, authority: :institution, involves_all: true)
      assign(:presenter, Projects::QuestionsIndexPresenter.new(
        project: project,
        current_step: 3
      ))

      render template: "projects/questions/index"

      doc = Capybara.string(rendered)
      expect(doc).to have_css("h2", text: "Federal")
      expect(doc).to have_css("h2", text: "State")
      expect(doc).to have_css("h2", text: "Local")
      expect(doc).to have_css("h2", text: "Institution")
    end

    it "displays relevant permit questions in each section" do
      project = build_stubbed(:project, involves_birds: true, involves_fish: false)
      federal_birds = create(:permit, authority: :federal, involves_birds: true, question: "Birds?")
      federal_fish = create(:permit, authority: :federal, involves_fish: true, question: "Fish?")
      state_birds = create(:permit, authority: :state, involves_birds: true, question: "Birds?")
      state_fish = create(:permit, authority: :state, involves_fish: true, question: "Fish?")
      local_birds = create(:permit, authority: :local, involves_birds: true, question: "Birds?")
      local_fish = create(:permit, authority: :local, involves_fish: true, question: "Fish?")
      institution_birds = create(:permit, authority: :institution, involves_birds: true, question: "Birds?")
      institution_fish = create(:permit, authority: :institution, involves_fish: true, question: "Fish?")
      assign(:presenter, Projects::QuestionsIndexPresenter.new(
        project: project,
        current_step: 3
      ))

      render template: "projects/questions/index"

      doc = Capybara.string(rendered)
      expect(doc).to have_css("ul.federal_permits_questions .question", text: "Birds?")
      expect(doc).to have_no_css("ul.federal_permits_questions .question", text: "Fish?")
      expect(doc).to have_css("ul.state_permits_questions .question", text: "Birds?")
      expect(doc).to have_no_css("ul.state_permits_questions .question", text: "Fish?")
      expect(doc).to have_css("ul.local_permits_questions .question", text: "Birds?")
      expect(doc).to have_no_css("ul.local_permits_questions .question", text: "Fish?")
      expect(doc).to have_css("ul.institution_permits_questions .question", text: "Birds?")
      expect(doc).to have_no_css("ul.institution_permits_questions .question", text: "Fish?")
    end

    it "has a Yes and No answer on each question, No is selected" do
      project = build_stubbed(:project)
      federal = create(:permit, authority: :federal, involves_all: true)
      assign(:presenter, Projects::QuestionsIndexPresenter.new(
        project: project,
        current_step: 3
      ))

      render template: "projects/questions/index"

      doc = Capybara.string(rendered)
      doc.has_css?("label:contains('Yes') + input[type='radio']:not([checked])")
      doc.has_css?("label:contains('No') + input[type='radio'][checked]")
    end

    it "does not display authorities that do not have questions" do
      project = build_stubbed(:project)
      federal = create(:permit, authority: :federal, involves_all: true)
      state = create(:permit, authority: :state, involves_all: false)
      assign(:presenter, Projects::QuestionsIndexPresenter.new(
        project: project,
        current_step: 3
      ))

      render template: "projects/questions/index"

      doc = Capybara.string(rendered)
      expect(doc).to have_css("ul.federal_permits_questions")
      expect(doc).to have_no_css("ul.state_permits_questions")
      expect(doc).to have_no_css("ul.local_permits_questions")
    end
  end

  describe "when there are reserve-specific questions to show" do
    it "has a reserve section for each reserve with answers to questions" do
      project = create(:project)
      reserve1 = create(:reserve, name: "Reserve 1")
      reserve2 = create(:reserve, name: "Reserve 2")
      question1 = create(:reserve_question, reserve: reserve1)
      create(:project_reserve_answer, reserve_question: question1, project: project)
      question2 = create(:reserve_question, reserve: reserve2)
      create(:project_reserve_answer, reserve_question: question2, project: project)
      assign(:presenter, Projects::QuestionsIndexPresenter.new(
        project: project,
        current_step: 3
      ))

      render template: "projects/questions/index"

      doc = Capybara.string(rendered)
      expect(doc).to have_css("h1", text: "Reserve-specific Questions")
      expect(doc).to have_css("h2", text: "Reserve 1")
      expect(doc).to have_css("h2", text: "Reserve 2")
    end

    it "displays relevant questions and answers in each section" do
      project = create(:project)
      reserve1 = create(:reserve, name: "Reserve 1")
      reserve2 = create(:reserve, name: "Reserve 2")
      question1 = create(:reserve_question, :text_question, reserve: reserve1, question: "Who?")
      create(:project_reserve_answer, reserve_question: question1, project: project, text_answer: "You!")
      question2 = create(:reserve_question, :text_question, reserve: reserve2, question: "Where?")
      create(:project_reserve_answer, reserve_question: question2, project: project, text_answer: "Here!")
      question3 = create(:reserve_question, :boolean_question, reserve: reserve2, question: "Does 2+2 = 4?")
      create(:project_reserve_answer, reserve_question: question3, project: project, boolean_answer: true)
      assign(:presenter, Projects::QuestionsIndexPresenter.new(
        project: project,
        current_step: 3
      ))

      render template: "projects/questions/index"

      doc = Capybara.string(rendered)
      expect(doc).to have_css("section.questions .question", text: "Who?")
      expect(doc).to have_css(".answers textarea", text: "You!")
      expect(doc).to have_css("section.questions .question", text: "Where?")
      expect(doc).to have_css(".answers textarea", text: "Here!")
      expect(doc).to have_css("section.questions .question", text: "Does 2+2 = 4?")
      expect(doc).to have_field("Yes", checked: true)
    end

    it "does not display reserves that do not have questions with answers" do
      project = create(:project)
      reserve1 = create(:reserve, name: "Reserve 1")
      reserve2 = create(:reserve, name: "Reserve 2")
      question1 = create(:reserve_question, reserve: reserve1)
      create(:project_reserve_answer, reserve_question: question1, project: project)
      assign(:presenter, Projects::QuestionsIndexPresenter.new(
        project: project,
        current_step: 3
      ))

      render template: "projects/questions/index"

      doc = Capybara.string(rendered)
      expect(doc).to have_css("h2", text: "Reserve 1")
      expect(doc).to have_no_css("h2", text: "Reserve 2")
    end
  end
end
