class Admin::NewFeatureNewPresenter
  def initialize(form:)
    @form = form
  end

  attr_reader :form

  delegate :new_feature, to: :form, prefix: true
end
