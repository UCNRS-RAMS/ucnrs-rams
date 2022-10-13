class Manager::Visits::VisitsFormPresenter < VisitsFormPresenter
  include Rails.application.routes.url_helpers
  EMAIL_OPTIONS = {
    composed_email: I18n.t("manager.visits.summary.presenter.composed_email"),
    silently_update: I18n.t("manager.visits.summary.presenter.update_silently"),
  }.freeze

  delegate :reserve, to: :visit

  def project_type_partial_path
    "manager/visits/detail/project_type"
  end

  def project_summary_path
    manager_reserve_project_path(reserve_id: reserve.id, id: project.id)
  end
  
  def project_partial_path
    "shared/visits/project"
  end

  def reserve_partial_path
    "shared/visits/reserve"
  end

  def show_browse_reserve_link
    false
  end

  def user_visits
    visit.user_visits.includes([:user, :institution]).map do |user_visit|
      Visits::UserVisitPresenter.new(user_visit)
    end
  end

  def amenity_visits
    visit.amenity_visits.includes([:amenity]).map do |amenity_visit|
      AmenityVisitPresenter.new(amenity_visit)
    end
  end

  def amenities_total
    "$#{value(amenity_visits.sum(&:subtotal))}"
  end

  def save_partial_path
    "manager/visits/detail/save"
  end

  def amenities_by_group_label
    amenity_scope
      .map(&method(:wrap_amenity_in_presenter))
      .group_by(&:group_label)
  end

  def message_text
    if visit.approved?
      reserve.approval_message
    end
  end

  def status_bar_disabled?
    visit.incomplete?
  end

  def email_options
    EMAIL_OPTIONS.invert
  end

  def project_team_members
    @project_team_members ||= Manager::Projects::TeamMembershipsIndexPresenter.new(
      reserve: reserve,
      project: project,
    ).team_memberships
  end

  def visit_date_range
    Manager::VisitShowPresenter.new(visit: visit, current_user: @user).visit_date_range
  end

  def submitted_date
    I18n.l(visit.created_at, format: :submitted_date)
  end

  private

  def amenity_scope
    (reserve&.amenities || Amenity.none)
      .not_disable
      .by_group_number
  end

  def value(num)
    "%0.2f" % [num]
  end

  def wrap_amenity_in_presenter(amenity)
    Manager::Visits::AmenityPresenter.new(
      amenity,
      form: form.amenity_form(amenity.id.to_s),
      user: @user,
    )
  end
end
