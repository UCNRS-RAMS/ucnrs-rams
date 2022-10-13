# frozen_string_literal: true

class Visits::UserVisitPresenter
  include Rails.application.routes.url_helpers

  def initialize(user_visit)
    @user_visit = user_visit
  end

  attr_reader :user_visit

  delegate :name, to: :institution, prefix: true
  delegate_missing_to :user_visit

  def user_visit_type
    if user_team_membership
      Projects::TeamMembershipPresenter.new(
        user_team_membership,
      ).project_role
    elsif group_user?
      ActionController::Base.helpers.image_tag "icon-users.svg"
    else
      ActionController::Base.helpers.image_tag "icon-user-navbar.svg"
    end
  end

  def user_role
    UserVisit.roles[role]
  end

  def user_full_name
    if guest_user?
      guest_name
    elsif group_user?
      I18n.t(".user_visits.user_visit.group_name", count: count)
    else
      user.full_name
    end
  end

  def date_range
    "#{formatted_date(arrives_at)} - #{formatted_date(departs_at)}"
  end

  def edit_user_visit_form_path
    edit_user_visit_path(id)
  end

  def user_visit_form_path
    user_visit_path(id)
  end

  def visit_user_visit_form_path
    visit_user_visit_path(visit.id, id)
  end

  def guest_user?
    user.id == 1 && guest_name.present?
  end

  def group_user?
    user.id == 1 && guest_name.blank?
  end

  def actual_user?
    user.id > 1
  end

  def project_role
    Projects::TeamMembershipPresenter.new(user_team_membership).project_role if user_team_membership
  end

  def date_of_use
    DateRangePresenter.new(start_date: arrives_at, end_date: departs_at).value("date_range.different_years")
  end

  private

  def visitor_icon
    group_user? ? "icon-users" : "icon-user-navbar"
  end

  def user_team_membership
    @user_team_membership ||= visit.project.team_memberships.find_by(user_id: user_id)
  end

  def formatted_date(datetime)
    I18n.l(datetime.to_date, format: :user_visit_date)
  end
end
