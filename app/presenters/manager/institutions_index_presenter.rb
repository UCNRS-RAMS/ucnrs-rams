# frozen_string_literal: true

class Manager::InstitutionsIndexPresenter
  DEFAULT_LIMIT_FOR_INDEX = 10

  def initialize(page: 1, filter: nil)
    @page = page
    @filter = InstitutionFilter.new(filter)
  end

  attr_reader :reserve, :page, :filter

  delegate :institution_search_filter,
    :institution_sort_by_filter,
    :institution_country_filter,
    :institution_state_filter,
    :institution_type_filter,
    to: :filter

  delegate :present?, to: :filter, prefix: true

  def institutions
    institution_scope.map do |institution|
      InstitutionPresenter.new(institution)
    end
  end

  def institution_scope
    Institution
      .search(institution_search_filter)
      .in_country(institution_country_filter)
      .in_state(institution_state_filter)
      .with_institution_type(institution_type_filter)
      .sorted_using(institution_sort_by_filter)
      .page(page)
      .per(DEFAULT_LIMIT_FOR_INDEX)
      .includes([:country, :state])
  end

  def institution_type_options
    Institution.institution_types
      .map { |key, _value| [I18n.t("universal.institution_types.#{key}"), key] }
      .unshift([I18n.t("all"), nil])
  end

  def institution_country_options
    Country
      .alphabetical_by_name
      .select(:name, :id)
      .map { |country| [country.name, country.id] }
      .unshift([I18n.t("all"), nil])
  end

  def institution_state_options
    State
      .in_country(institution_country_filter)
      .alphabetical_by_name
      .map { |state| [state.name, state.id] }
      .unshift([I18n.t("select"), nil])
  end

  def country_have_states?
    State
      .in_country(institution_country_filter)
      .present?
  end

  def institution_sort_by_options
    {
      I18n.t("manager.institutions.search.name") => :name,
      I18n.t("manager.institutions.search.date_created") => :created_at,
    }
  end
end
