class ReserveQuestionForm
  include ActiveModel::Model

  def model_name
    ActiveModel::Name.new(ReserveQuestion)
  end

  def initialize(reserve_question: nil, params: {})
    @reserve_question = reserve_question || ReserveQuestion.new
    assign(params)
  end

  attr_reader :reserve_question
  delegate :valid?, :validate, :errors, to: :reserve_question
  delegate_missing_to :reserve_question

  def save
    begin
      reserve_question.save!
      true
    rescue ActiveRecord::RecordInvalid => e
      Rails.logger.error(e)
      false
    end
  end

  private

  def assign(params)
    params.each do |key, value|
      self.send("#{key}=", value)
    end
  end
end
