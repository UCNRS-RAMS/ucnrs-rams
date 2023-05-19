# frozen_string_literal: true

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

  private

  def amenity_scope
    (reserve&.amenities || Amenity.none)
      .not_disable
      .by_group_number
  end

  def wrap_amenity_in_presenter(amenity)
    Manager::Visits::AmenityPresenter.new(
      amenity,
      form: form.amenity_form(amenity.id.to_s),
      user: @user,
    )
  end
end
