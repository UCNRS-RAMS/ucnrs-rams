# frozen_string_literal: true

class Visits::UserVisitEditPresenter
  include Rails.application.routes.url_helpers

  def initialize(form:)
    @form = form
  end

  attr_reader :form

  delegate :id, :errors, to: :form

  delegate_missing_to :editing_user_visit

  def editing_user_visit
    @editing_user_visit ||= Visits::UserVisitPresenter.new(
      form.user_visit,
    )
  end

  def user_days_partial
    "/shared/empty"
  end

  def user_role_options
    UserVisit.roles.map { |key, value| [value, key] }
  end

  def user_visit_form_path
    user_visit_path(id)
  end
end
