class Projects::PermitPresenter
  def initialize(permit: , answer: nil, show_error: false)
    @permit = permit
    @permit_answer = answer
    @error = show_error
  end

  def render_values
    {
      partial: "projects/questions/permit",
      locals: { permit: self },
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

  def answer
    if permit.respond_to?(:answer)
      permit_answer || permit.answer
    else
      "0"
    end
  end

  def form
    self
  end

  attr_reader :error

  private

  attr_reader :permit, :permit_answer
end
