class Manager::ReserveInfo::ReserveQuestionsIndexPresenter
  def initialize(reserve:)
    @reserve = reserve
  end

  def reserve_questions
    reserve_questions_scope
      .map{ |reserve_question| ReserveQuestionPresenter.new(reserve_question) }
      .group_by(&:location)
  end

  def reserve_questions_scope
    reserve
      .reserve_questions
      .by_location
      .in_order
  end

  private

  attr_reader :reserve
end
