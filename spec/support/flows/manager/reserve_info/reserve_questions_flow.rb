class Manager::ReserveInfo::ReserveQuestionsFlow
  def initialize(page, reserve, user)
    @page = page
    @reserve = reserve
    @user = user
  end

  def visit_manager_reserve_info_reserve_questions_index_page(reserve)
    page.visit("/manager/reserves/#{reserve.id}/reserve_info/reserve_questions")
  end

  def on_manager_reserve_info_reserve_questions_index_page?
    page.has_css?("body.manager.reserve_questions.reserve_questions-index")
  end

  def click_new_reserve_question
    page.find("table.reserve_questions_table a", text: "New").click
  end

  def click_edit_reserve_question(reserve_question)
    page.find("a[href='#{edit_path(reserve_question)}']").click
  end

  def has_reserve_question_modal_displayed?(title)
    page.has_css?(".modal-content h2", text: title, visible: true)
  end

  def has_no_reserve_question_modal_displayed?(title)
    page.has_no_css?(".modal-content h2", text: title, visible: true)
  end

  def click_modal_button(name)
    page.find(".modal-content button", text: name).click
  end

  def choose_ignore_involvements(answer)
    page.find("#reserve_question_ignore_involvements_#{answer}", visible: :all).click
  end

  def has_involvement_checkboxes?
    page.has_css?("#reserve_question_involves_mammals", visible: true)
  end

  def has_no_involvement_checkboxes?
    page.has_no_css?("#reserve_question_involves_mammals", visible: true)
  end

  def check_involvement(involvement)
    page.find("#reserve_question_#{involvement}", visible: :all).click
  end

  def has_checked_involvement?(involvement)
    page.has_field?("reserve_question_#{involvement}", checked: true, visible: :all)
  end

  private

  attr_reader :page, :reserve, :user

  def edit_path(reserve_question)
    "/manager/reserves/#{reserve.id}/reserve_info/reserve_questions/#{reserve_question.id}/edit"
  end
end
