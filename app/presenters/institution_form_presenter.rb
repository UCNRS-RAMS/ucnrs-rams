# frozen_string_literal: true

class InstitutionFormPresenter
  NAME_PLACEHOLDER = "Institution Name".freeze
  CITY_PLACEHOLDER = "Institution City".freeze

  attr_reader :form

  def initialize(form = nil)
    @form = form || InstitutionForm.new
  end

  delegate :institution, to: :form, prefix: true

  def institution_type_options
    Institution.institution_types.map do |key, value|
      [value, key]
    end
  end

  def name_placeholder
    NAME_PLACEHOLDER
  end

  def city_placeholder
    CITY_PLACEHOLDER
  end
end
