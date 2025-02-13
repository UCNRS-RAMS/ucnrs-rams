class Reserves::ProjectTypesIndexPresenter
  CHECK_ICON = "check.svg".freeze
  UNCHECK_ICON = "dot.svg".freeze
  ICON_TO_ALT = {
    CHECK_ICON => "alt.checked",
    UNCHECK_ICON => "alt.unchecked",
  }.freeze

  def initialize()

  end

  def reserves
    Reserve
      .alphabetized
      .select(:name,
        :research_projects_accepted,
        :class_projects_accepted,
        :conference_projects_accepted,
        :public_projects_accepted
      )
      .map do |reserve|
        ReservePresenter.new(reserve)
      end
  end

  def icon(for_column)
    if for_column == true
      CHECK_ICON
    else
      UNCHECK_ICON
    end
  end

  def icon_alt_i18n_key(for_column)
    ICON_TO_ALT[icon(for_column)]
  end

  private
end
