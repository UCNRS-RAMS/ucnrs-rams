class Projects::PermitPresenter
  def initialize(permit)
    @permit = permit
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

  private

  attr_reader :permit
end
