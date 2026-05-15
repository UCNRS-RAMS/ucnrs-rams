# frozen_string_literal: true

class Visits::UserVisitEditPresenter
  include Rails.application.routes.url_helpers

  def initialize(form:, display_institution_form: false)
    @form = form
    @display_institution_form = display_institution_form
  end

  attr_reader :form, :display_institution_form

  delegate :id, :errors, to: :form

  delegate_missing_to :editing_user_visit

  def institution_form_presenter
    InstitutionFormPresenter.new(@form.institution_form)
  end

  def institution_fields_path
    if display_institution_form
      "modals/institution_fields/institution_fields"
    else
      "modals/institution_fields/institution_search_field"
    end
  end

  def editing_user_visit
    @editing_user_visit ||= Visits::UserVisitPresenter.new(
      form.user_visit,
    )
  end

  def user_days_partial
    "/shared/empty"
  end

  def user_role_options
    UserVisit.roles.except(:no_selection).map do |key, _value|
      [I18n.t("universal.roles.#{key}"), key]
    end
  end

  def user_visit_form_path
    user_visit_path(id)
  end
end
