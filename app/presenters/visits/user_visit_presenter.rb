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
    else
      ActionController::Base.helpers.image_tag visitor_icon
    end
  end

  def user_full_name
    group_user? ? I18n.t(".user_visits.user_visit.group_name", count: count) : user.full_name
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

  private

  def visitor_icon
    group_user? ? "icon-users" : "icon-user-navbar"
  end

  def user_team_membership
    @user_team_membership ||= visit.project.team_memberships.find_by(user_id: user_id)
  end

  def group_user?
    user.id == 1
  end

  def formatted_date(datetime)
    I18n.l(datetime.to_date, format: :user_visit_date)
  end
end
