# frozen_string_literal: true

class Manager::InstitutionEditPresenter
  def initialize(form:)
    @form = form
  end

  attr_reader :form

  delegate :institution, to: :form, prefix: true
  delegate :id, :name, :country, to: :form_institution, prefix: :institution

  def institution_type_options
    Institution.institution_types
      .map { |key, _value| [I18n.t("universal.institution_types.#{key}"), key] }
  end

  def institution_country_options
    Country
      .alphabetical_by_name
      .pluck(:name, :id)
  end

  def institution_state_options
    State
      .in_country(institution_country)
      .alphabetical_by_name
      .pluck(:name, :id)
  end
end
