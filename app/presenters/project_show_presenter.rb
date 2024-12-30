# frozen_string_literal: true

class ProjectShowPresenter
  include Rails.application.routes.url_helpers

  def initialize(project)
    @project = project
  end

  delegate :id, to: :project, prefix: true
  delegate :id, to: :reserve, prefix: true

  attr_reader :project

  delegate_missing_to :project

  def project_type_for_new_visit_link
    case project.project_type
    when "research"
      "research"
    when "class"
      "university_class"
    when "meeting"
      "meeting"
    when "public_use"
      "public_use"
    when "housing"
      "housing"
    else
      nil
    end
  end

  def project_status
    "#{status&.capitalize} Project"
  end

  def submitted_at
    project.submitted_at ? I18n.l(project.submitted_at, format: :project_summary_date_time) : "Not yet submitted"
  end

  def principal_investigators_list
    principal_investigators.map{ |principal_investigator| principal_investigator.user.full_name }.to_sentence
  end

  def applicant_name
    applicant.full_name
  end

  def abstract
    project.abstract.present? ? project.abstract : not_applicable
  end

  def thesis_title
    project.thesis_title.present? ? project.thesis_title : not_applicable
  end

  def project_involves
    involves.present? ? involves&.to_sentence : none
  end

  def discipline
    project.discipline.present? ? project.discipline : not_applicable
  end

  def display_approved_permits?
    approved_permits.present?
  end

  def partial_name
    "shared/projects/#{project_type.parameterize.underscore}_show"
  end

  def timeframe
    if project_requires_dates?
      DateRangePresenter.value(start_date: start_date, end_date: end_date)
    else
      not_applicable
    end
  end

  def sidebar_partial
    open? ? "projects/completed_project_sidebar" : "projects/incomplete_project_sidebar"
  end

  def method_remove_organisms_statement
    I18n.t("projects.show.method_remove_organisms") if method_remove_organisms
  end

  def method_transfer_organisms_statement
    I18n.t("projects.show.method_transfer_organisms") if method_transfer_organisms
  end

  def method_chemicals_statement
    I18n.t("projects.show.method_chemicals", chemical_list: method_chemicals_list) if method_chemicals
  end

  def method_study_non_native_species_statement
    I18n.t("projects.show.method_study_non_native_species") if method_study_non_native_species
  end

  def method_soil_disturbance_statement
    I18n.t("projects.show.method_soil_disturbance") if method_soil_disturbance
  end

  def method_long_term_structures_statement
    I18n.t("projects.show.method_long_term_structures") if method_long_term_structures
  end

  def method_description
    project.method_description.present? ? project.method_description : not_applicable
  end

  def method_study_area
    project.method_study_area.present? ? project.method_study_area : not_applicable
  end

  def team_memberships
    project_team_memberships
      .is_active
      .includes(:user, :institution)
      .map do |team_membership|
        Projects::TeamMembershipPresenter.new(team_membership)
      end
  end

  def fundings
    project.fundings.map do |funding|
      Projects::FundingPresenter.new(funding)
    end
  end

  def permit_answers
    ProjectPermitAnswer
      .with_permits_authority_column
      .for_project(project)
      .for_answer(true)
      .includes([:permit])
      .map{ |permit_answer| ProjectPermitAnswerPresenter.new(permit_answer) }
      .group_by(&:authority)
  end

  def reserve_answers
    ProjectReserveAnswer
      .includes([reserve_question: :reserve])
      .with_reserve_name_column
      .with_affirmative_answer
      .for_project(project)
      .map{ |reserve_answer| ProjectReserveAnswerPresenter.new(reserve_answer) }
      .group_by(&:reserve_name)
  end

  def visits
    project
      .visits
      .recent_start_date_first
      .includes(:reserve, :user_visits, :amenity_visits)
      .map do |visit|
        VisitPresenter.new(visit)
    end
  end

  def edit_team_membership_path
    project_team_memberships_path(project_id)
  end

  def edit_funding_path
    project_fundings_path(project_id)
  end

  def edit_questions_path
    project_questions_path(project_id)
  end

  private

  delegate :team_memberships, to: :project, prefix: true

  def project_requires_dates?
    start_date.present? && end_date.present?
  end

  def principal_investigators
    project_team_memberships.principal_investigators.includes(:user)
  end

  def involves
    [].tap do |involves|
      involves << I18n.t("projects.show.mammals") if involves_mammals
      involves << I18n.t("projects.show.reptiles") if involves_reptiles
      involves << I18n.t("projects.show.amphibians") if involves_amphibians
      involves << I18n.t("projects.show.fish") if involves_fish
      involves << I18n.t("projects.show.birds") if involves_birds
      involves << I18n.t("projects.show.plants") if involves_plants_fungi_soil
      involves << I18n.t("projects.show.fungi") if involves_plants_fungi_soil
      involves << I18n.t("projects.show.soil") if involves_plants_fungi_soil
      involves << I18n.t("projects.show.threatened") if involves_threatened_endangered_species
      involves << I18n.t("projects.show.endangered") if involves_threatened_endangered_species
      involves << I18n.t("projects.show.species_of_special_concern") if involves_threatened_endangered_species
    end.flatten
  end

  def not_applicable
    I18n.t("not_applicable")
  end

  def none
    I18n.t("none")
  end
end
