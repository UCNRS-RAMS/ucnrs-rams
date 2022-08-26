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

  def add_visitor_link_class(partial_name)
    partial_name == add_visitor_partial ? "selected" : ""
  end

  def user_visit_form_path
    visit_user_visits_path(visit.id, add_visitor_partial: add_visitor_partial)
  end

  def new_user_visit_path(params)
    new_visit_user_visit_path(visit.id, params)
  end

  def user_role_options
    UserVisit.roles.map { |key, value| [value, key] }
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
    "visits/user_visits/#{add_visitor_partial}"
  end

  def user_visits
    visit.user_visits.includes([:user, :institution])
      .map do |user_visit|
      Visits::UserVisitPresenter.new(
        user_visit,
      )
    end
  end

  def project_team_members
    visit.project.team_memberships.includes(:institution, :user).map do |user_team_membership|
      Projects::TeamMembershipPresenter.new(
        user_team_membership,
      )
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
      role: team_membership.user_role,
      count: 1,
    } }
  end
end
