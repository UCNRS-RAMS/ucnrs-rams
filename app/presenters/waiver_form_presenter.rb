class WaiverFormPresenter
  def initialize(form: nil)
    @form = form || WaiverForm.new
  end

  attr_reader :form
  delegate_missing_to :form
end
