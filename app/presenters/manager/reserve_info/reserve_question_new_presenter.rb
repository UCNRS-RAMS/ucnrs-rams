class Manager::ReserveInfo::ReserveQuestionNewPresenter
  def initialize(form:)
    @form = form
  end

  attr_reader :form

  delegate :reserve_question, to: :form, prefix: true

  def question_type_options
    ReserveQuestion.question_types.map {|key, _value| [translate(key), key]}
  end

  def location_options
    ReserveQuestion.locations.map {|key, _value| [translate(key), key]}
  end

  private

  def translate(key)
    I18n.t("manager.reserve_info.reserve_questions.new.#{key}")
  end
end
