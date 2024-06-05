# frozen_string_literal: true

class Mail::PermitPresenter
  def initialize(permit)
    @permit = permit
  end

  def render_values
    {
      partial: "mails/shared/questions/permit",
      locals: { question: self },
    }
  end

  delegate_missing_to :permit

  def urls
    {
      url1 => url1_description,
      url2 => url2_description,
      url3 => url3_description,
    }.select do |url, description|
      url.present? && description.present?
    end
  end

  def answer_text
    if ActiveModel::Type::Boolean.new.cast(permit.answer) == true
      I18n.t("yes")
    else
      I18n.t("no")
    end
  end

  private

  attr_reader :permit
end
