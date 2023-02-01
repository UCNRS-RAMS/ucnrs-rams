# frozen_string_literal: true

class Visits::UserVisitFormPresenter
  include Rails.application.routes.url_helpers

def initialize(current_user:, add_visitor_partial:, show_add_guest_modal: false, form: nil)
    @form = form || UserVisitForm.new
    @current_user = current_user
    @add_visitor_partial = add_visitor_partial
    @show_add_guest_modal = show_add_guest_modal
  end

  attr_reader :form, :current_user, :add_visitor_partial, :show_add_guest_modal

  delegate :id, :errors, to: :form

  delegate_missing_to :form

  def team_member_class(user)
    visitor?(user) ? "visitor" : ""
  end

  def warning_message_class
    if user_visits_not_in_amenity_date_range?
      "user-visits-warning"
    else
      "no-warning"
    end
  end

  def reset_visitor_partial
    @add_visitor_partial = nil
  end

  def add_visitor_link_class(partial_name)
    partial_name == add_visitor_partial ? "selected" : ""
  end

  def user_visit_form_path(team_membership=nil)
    if team_membership.present?
      new_visit_user_visit_path(visit_id: visit.id, user_id: team_membership.user_id, institution_id: team_membership.user.institution_id)
    else
      visit_user_visits_path(visit.id, add_visitor_partial: add_visitor_partial)
    end
  end

  def new_user_visit_path(params)
    new_visit_user_visit_path(visit.id, params)
  end

  def user_role_options
    UserVisit.roles.except(:reserve_staff).map do |key, value|
      [I18n.t("universal.roles.#{key}"), key]
    end
  end

  def institution_options
    Institution.where(id: [*Institution::UC_IDS, *Institution::GENERIC_INSTITUTION_IDS]).pluck(:name, :id)
  end

  def default_institution
    if institution_options.map(&:second).include? current_user.institution.id
      current_user.institution.id
    else
      Institution.find_by(id: Institution::GENERIC_INSTITUTION_IDS,
        institution_type: current_user.institution.institution_type).id
    end
  end

  def can_add_project_user?
    visit.project.team_memberships.find_by(user_id: current_user.id)&.can_add_project_user
  end

  def add_visitor_partial_path
    "shared/visits/user_visits/#{add_visitor_partial}"
  end

  def user_visits
    visit.user_visits.includes([:user, :institution])
      .map do |user_visit|
      Visits::UserVisitPresenter.new(
        user_visit,
      )
    end
  end

  def click_add_visitor_text
    if can_add_project_user?
      I18n.translate("shared.visits.user_visits.click_add_visitor", or: "or ")
    else
      I18n.translate("shared.visits.user_visits.click_add_visitor", or: "")
    end
  end

  def project_team_members
    visit.project.team_memberships.includes(:institution, :user).map do |user_team_membership|
      Projects::TeamMembershipPresenter.new(
        user_team_membership,
      )
    end
  end

  def add_visitor_text(user)
    if visitor?(user)
      I18n.translate(".shared.visits.user_visits.team_member.add_to_visitor_again")
    else
      I18n.translate(".shared.visits.user_visits.team_member.add_to_visitor")
    end
  end

  def visitor?(user)
    visit&.user_visits&.find_by(user_id: user.id).present?
  end

  def add_team_member_params(team_membership)
    { user_visit: {
      user_id: team_membership.user_id,
      visit_id: visit_id,
      institution_id: team_membership.institution_id,
      role: team_membership.team_membership_user_role,
      count: 1,
    } }
  end

  private

  def user_visits_not_in_amenity_date_range?
    if visit.amenity_visits.present? && visit.user_visits.present?
      return !visit.user_visits.in_visit_amenities_range?(visit)
    else
      false
    end
  end
end
