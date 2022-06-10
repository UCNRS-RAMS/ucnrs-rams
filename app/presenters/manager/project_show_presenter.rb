# frozen_string_literal: true

class Manager::ProjectShowPresenter < ProjectShowPresenter
  def created_at(format: :project_summary_box_time)
    project.created_at ? I18n.l(project.created_at, format: format) : ""
  end

  def updated_at(format: :project_summary_box_time)
    project.updated_at ? I18n.l(project.updated_at, format: format) : ""
  end

  def owner_name
    owner.full_name
  end

  def project_type
    project.project_type.titleize
  end

  def reserve_names
    visits&.map(&:requested_reserve_name)&.uniq&.join(", ")
  end

  def project_info
    "#{status.titleize} #{project_type.titleize} Project Created: #{created_at(format: :project_summary_time)}"
  end

  def team_memberships
    project_team_memberships
      .includes(:user, :institution)
      .map do |team_membership|
        Projects::TeamMembershipPresenter.new(team_membership)
      end.sort_by(&:desc_status_asc_role)
  end

  def visits
    project
      .visits
      .recent_start_date_first
      .includes(:reserve)
      .map do |visit|
      VisitPresenter.new(visit)
    end
  end
end
