require "rails_helper"

RSpec.describe "Manager - Reserve Info - Reserve Questions" do
  def sign_in_as_manager_of(reserve)
    user = create(:user, :confirmed)
    create(:reserve_personnel, user: user, reserve: reserve)
    sign_in(user)
    user
  end

  describe "the ignore involvements toggle" do
    it "starts a new question on every project, with the checkboxes hidden", js: true do
      reserve = create(:reserve)
      user = sign_in_as_manager_of(reserve)

      flow = Manager::ReserveInfo::ReserveQuestionsFlow.new(page, reserve, user)
      flow.visit_manager_reserve_info_reserve_questions_index_page(reserve)
      flow.click_new_reserve_question

      expect(flow).to have_reserve_question_modal_displayed("New Reserve Question")
      expect(flow).to have_no_involvement_checkboxes

      flow.choose_ignore_involvements(false)
      expect(flow).to have_involvement_checkboxes

      flow.choose_ignore_involvements(true)
      expect(flow).to have_no_involvement_checkboxes
    end

    it "hides them on load when the question already ignores involvements", js: true do
      reserve = create(:reserve)
      user = sign_in_as_manager_of(reserve)
      reserve_question = create(
        :reserve_question,
        reserve: reserve,
        ignore_involvements: true,
        involves_fish: true,
      )

      flow = Manager::ReserveInfo::ReserveQuestionsFlow.new(page, reserve, user)
      flow.visit_manager_reserve_info_reserve_questions_index_page(reserve)
      flow.click_edit_reserve_question(reserve_question)

      expect(flow).to have_reserve_question_modal_displayed("Edit Reserve Question")
      expect(flow).to have_no_involvement_checkboxes
      expect(flow).to have_checked_involvement(:involves_fish)

      flow.choose_ignore_involvements(false)
      expect(flow).to have_involvement_checkboxes
      expect(flow).to have_checked_involvement(:involves_fish)
    end
  end

  describe "saving the ignore involvements choice" do
    it "persists ignore_involvements and leaves the hidden involvements alone", js: true do
      reserve = create(:reserve)
      user = sign_in_as_manager_of(reserve)
      reserve_question = create(
        :reserve_question,
        reserve: reserve,
        ignore_involvements: false,
        involves_fish: true,
      )

      flow = Manager::ReserveInfo::ReserveQuestionsFlow.new(page, reserve, user)
      flow.visit_manager_reserve_info_reserve_questions_index_page(reserve)
      flow.click_edit_reserve_question(reserve_question)

      expect(flow).to have_reserve_question_modal_displayed("Edit Reserve Question")
      expect(flow).to have_involvement_checkboxes

      flow.choose_ignore_involvements(true)
      expect(flow).to have_no_involvement_checkboxes
      flow.click_modal_button("Update")

      expect(flow).to have_no_reserve_question_modal_displayed("Edit Reserve Question")
      expect(reserve_question.reload.ignore_involvements).to eq true
      expect(reserve_question.involves_fish).to eq true
    end

    it "saves threatened, endangered species as an involvement", js: true do
      reserve = create(:reserve)
      user = sign_in_as_manager_of(reserve)
      reserve_question = create(:reserve_question, reserve: reserve, ignore_involvements: false)

      flow = Manager::ReserveInfo::ReserveQuestionsFlow.new(page, reserve, user)
      flow.visit_manager_reserve_info_reserve_questions_index_page(reserve)
      flow.click_edit_reserve_question(reserve_question)

      expect(flow).to have_reserve_question_modal_displayed("Edit Reserve Question")
      expect(flow).to have_involvement_checkboxes

      flow.check_involvement(:involves_threatened_endangered_species)
      flow.click_modal_button("Update")

      expect(flow).to have_no_reserve_question_modal_displayed("Edit Reserve Question")
      expect(reserve_question.reload.involves_threatened_endangered_species).to eq true
      expect(reserve_question.threatened_endangered_flag).to be_falsey
    end

    it "persists turning it back off", js: true do
      reserve = create(:reserve)
      user = sign_in_as_manager_of(reserve)
      reserve_question = create(:reserve_question, reserve: reserve, ignore_involvements: true)

      flow = Manager::ReserveInfo::ReserveQuestionsFlow.new(page, reserve, user)
      flow.visit_manager_reserve_info_reserve_questions_index_page(reserve)
      flow.click_edit_reserve_question(reserve_question)

      expect(flow).to have_reserve_question_modal_displayed("Edit Reserve Question")

      flow.choose_ignore_involvements(false)
      flow.click_modal_button("Update")

      expect(flow).to have_no_reserve_question_modal_displayed("Edit Reserve Question")
      expect(reserve_question.reload.ignore_involvements).to eq false
    end
  end
end
