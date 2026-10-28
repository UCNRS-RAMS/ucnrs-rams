require "rails_helper"

RSpec.describe Manager::ReserveInfo::ReserveQuestionsController, type: :request do
  let(:reserve) { create(:reserve) }
  let(:manager) do
    user = create(:user, :confirmed)
    create(:reserve_personnel, user: user, reserve: reserve)
    user
  end

  let(:turbo_stream_headers) { { "Accept" => "text/vnd.turbo-stream.html, text/html" } }

  let(:question_params) do
    {
      location: "project",
      question_type: "text",
      question: "How many researchers will attend?",
      sort_order: 1,
      visible: "true",
      answer_required: "false",
      research: "true",
      university_class: "true",
      public_use: "true",
      housing: "true",
      conference: "false"
    }
  end

  def index_path
    "/manager/reserves/#{reserve.id}/reserve_info/reserve_questions"
  end

  def turbo_stream_template(target)
    fragment = Nokogiri::HTML.fragment(response.body)
    node = fragment.at_css(%(turbo-stream[target="#{target}"] template))
    Capybara.string(node&.inner_html.to_s)
  end

  describe "GET reserve questions index" do
    it "renders the reserve questions table for a reserve manager" do
      create(:reserve_question, reserve: reserve, question: "Existing question text")
      sign_in(manager)

      get index_path

      expect(response).to be_ok
      page = Capybara.string(response.body)
      expect(page).to have_css("turbo-frame#reserve_questions-table")
      expect(page).to have_content("Existing question text")
    end

    it "refreshes the questions table and closes the modal over turbo stream" do
      create(:reserve_question, reserve: reserve, question: "Existing question text")
      sign_in(manager)

      get index_path, headers: turbo_stream_headers

      expect(response.media_type).to eq("text/vnd.turbo-stream.html")
      page = Capybara.string(response.body)
      expect(page).to have_css('turbo-stream[action="replace"][target="modal-content"]')
      expect(page).to have_css('turbo-stream[action="replace"][target="reserve_questions-table"]')
      expect(response.body).to include("Existing question text")
    end

    it "rejects a user who is not personnel of the reserve" do
      sign_in(create(:user, :confirmed))

      get index_path

      expect(response).to have_http_status(:redirect)
      expect(flash[:alert]).to eq(I18n.t("manager.not_a_manager_of_reserve"))
    end
  end

  describe "GET new reserve question" do
    it "renders the new question modal that ignores involvements by default" do
      sign_in(manager)

      get "#{index_path}/new", headers: turbo_stream_headers

      expect(response).to be_ok
      page = turbo_stream_template("modal-content")
      expect(page).to have_css("form")
      expect(page).to have_css(".involvement-scope input.involvement-scope-ignore")
      expect(page).to have_css(".involvement-scope ~ .involvement-scope-fields")
      expect(page).to have_css(
        'input[name="reserve_question[ignore_involvements]"][value="true"][checked]'
      )
    end
  end

  describe "GET edit reserve question" do
    it "keeps the recorded involvements while the question ignores them" do
      reserve_question = create(
        :reserve_question,
        reserve: reserve,
        ignore_involvements: true,
        involves_fish: true,
      )
      sign_in(manager)

      get "#{index_path}/#{reserve_question.id}/edit", headers: turbo_stream_headers

      expect(response).to be_ok
      page = turbo_stream_template("modal-content")
      expect(page).to have_css(
        'input[name="reserve_question[ignore_involvements]"][value="true"][checked]'
      )
      expect(page).to have_css('input[name="reserve_question[involves_fish]"][checked]')
    end
  end

  describe "POST reserve questions" do
    it "creates a text reserve question" do
      sign_in(manager)

      expect {
        post index_path,
          params: { reserve_question: question_params },
          headers: turbo_stream_headers
      }.to change(ReserveQuestion, :count).by(1)

      reserve_question = reserve.reserve_questions.last
      expect(reserve_question.question_type).to eq("text")
      expect(reserve_question.question).to eq("How many researchers will attend?")
      expect(reserve_question.location).to eq("project")
      expect(reserve_question.sort_order).to eq(1)
      expect(reserve_question.visible).to be true
      expect(response).to redirect_to(index_path)

      get index_path, headers: turbo_stream_headers

      page = Capybara.string(response.body)
      expect(page).to have_css('turbo-stream[action="replace"][target="reserve_questions-table"]')
      expect(response.body).to include("How many researchers will attend?")
    end

    it "creates a boolean reserve question" do
      sign_in(manager)

      expect {
        post index_path,
          params: {
            reserve_question: question_params.merge(
              question_type: "boolean",
              question: "Will you bring a boat?",
            )
          },
          headers: turbo_stream_headers
      }.to change(ReserveQuestion, :count).by(1)

      expect(reserve.reserve_questions.last.question_type).to eq("boolean")
    end

    it "re-renders the new question modal when the question is invalid" do
      sign_in(manager)

      expect {
        post index_path,
          params: { reserve_question: question_params.merge(question: "") },
          headers: turbo_stream_headers
      }.not_to change(ReserveQuestion, :count)

      expect(response).to have_http_status(:unprocessable_content)
      page = Capybara.string(response.body)
      expect(page).to have_css('turbo-stream[action="update"][target="modal-content"]')
      expect(response.body).to include("reserve_question[question]")
    end

    it "rejects a user who is not personnel of the reserve" do
      sign_in(create(:user, :confirmed))

      expect {
        post index_path, params: { reserve_question: question_params }
      }.not_to change(ReserveQuestion, :count)

      expect(response).to have_http_status(:redirect)
      expect(flash[:alert]).to eq(I18n.t("manager.not_a_manager_of_reserve"))
    end
  end

  describe "PATCH reserve question" do
    it "persists ignore_involvements and leaves the hidden involvements alone" do
      reserve_question = create(
        :reserve_question,
        reserve: reserve,
        ignore_involvements: false,
        involves_fish: true,
      )
      sign_in(manager)

      patch "#{index_path}/#{reserve_question.id}",
        params: { reserve_question: { ignore_involvements: "true" } },
        headers: turbo_stream_headers

      expect(response).to redirect_to(index_path)

      reserve_question.reload
      expect(reserve_question.ignore_involvements).to be true
      expect(reserve_question.involves_fish).to be true
    end

    it "saves threatened, endangered species as an involvement" do
      reserve_question = create(
        :reserve_question,
        reserve: reserve,
        ignore_involvements: false,
        threatened_endangered_flag: false,
      )
      sign_in(manager)

      patch "#{index_path}/#{reserve_question.id}",
        params: { reserve_question: { involves_threatened_endangered_species: "true" } },
        headers: turbo_stream_headers

      expect(response).to redirect_to(index_path)

      reserve_question.reload
      expect(reserve_question.involves_threatened_endangered_species).to be true
      expect(reserve_question.threatened_endangered_flag).to be_falsey
    end

    it "persists turning ignore_involvements back off" do
      reserve_question = create(:reserve_question, reserve: reserve, ignore_involvements: true)
      sign_in(manager)

      patch "#{index_path}/#{reserve_question.id}",
        params: { reserve_question: { ignore_involvements: "false" } },
        headers: turbo_stream_headers

      expect(response).to redirect_to(index_path)
      expect(reserve_question.reload.ignore_involvements).to be false
    end

    it "switches the answer type between text and boolean" do
      reserve_question = create(:reserve_question, reserve: reserve, question_type: :text)
      sign_in(manager)

      patch "#{index_path}/#{reserve_question.id}",
        params: { reserve_question: { question_type: "boolean" } },
        headers: turbo_stream_headers

      expect(response).to redirect_to(index_path)
      expect(reserve_question.reload.question_type).to eq("boolean")
    end

    it "re-renders the edit question modal when the question is invalid" do
      create(
        :reserve_question,
        reserve: reserve,
        location: :project,
        sort_order: 1,
        question: "Existing question",
      )
      reserve_question = create(
        :reserve_question,
        reserve: reserve,
        location: :project,
        sort_order: 2,
        question: "Second question",
      )
      sign_in(manager)

      patch "#{index_path}/#{reserve_question.id}",
        params: { reserve_question: { sort_order: 1 } },
        headers: turbo_stream_headers

      expect(response).to have_http_status(:unprocessable_content)
      page = Capybara.string(response.body)
      expect(page).to have_css('turbo-stream[action="update"][target="modal-content"]')
      expect(reserve_question.reload.sort_order).to eq(2)
    end

    it "rejects a user who is not personnel of the reserve" do
      reserve_question = create(:reserve_question, reserve: reserve, question_type: :text)
      sign_in(create(:user, :confirmed))

      patch "#{index_path}/#{reserve_question.id}",
        params: { reserve_question: { question_type: "boolean" } }

      expect(response).to have_http_status(:redirect)
      expect(flash[:alert]).to eq(I18n.t("manager.not_a_manager_of_reserve"))
      expect(reserve_question.reload.question_type).to eq("text")
    end
  end
end
