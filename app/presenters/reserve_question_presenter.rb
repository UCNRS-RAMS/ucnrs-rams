# frozen_string_literal: true

class ReserveQuestionPresenter
  def initialize(reserve_question)
    @reserve_question = reserve_question
  end

  delegate :id,
    :location,
    :sort_order,
    :question,
    :statement,
    :answer_required,
    :visible,
    to: :reserve_question

  def location_project_types
    [].tap do |arr|
      arr << I18n.t("research") if reserve_question.research?
      arr << I18n.t("university_class") if reserve_question.university_class?
      arr << I18n.t("public_use") if reserve_question.public_use?
      arr << I18n.t("housing") if reserve_question.housing?
      arr << I18n.t("conference") if reserve_question.conference?
    end
  end

  def type
    case reserve_question.question_type
    when "text" then I18n.t("text")
    when "boolean" then I18n.t("yes_no")
    end
  end

  private

  attr_reader :reserve_question
end
