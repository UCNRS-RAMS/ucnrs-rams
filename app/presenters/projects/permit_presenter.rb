class Projects::PermitPresenter
  def initialize(permit)
    @permit = permit
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

  def form
    self
  end

  private

  attr_reader :permit
end
