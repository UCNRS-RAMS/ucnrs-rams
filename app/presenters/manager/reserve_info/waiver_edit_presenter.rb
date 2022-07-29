class Manager::ReserveInfo::WaiverEditPresenter
  def initialize(form:)
    @form = form
  end

  attr_reader :form

  delegate :waiver, to: :form, prefix: true
end
