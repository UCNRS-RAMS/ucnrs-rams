# frozen_string_literal: true

class ProjectShowPresenter
  def initialize(project)
    @project = project
  end

  delegate :id, to: :project, prefix: true

  delegate_missing_to :project

  def project_status
    "#{status&.capitalize} Application"
  end

  def submitted_at
    project.submitted_at ? I18n.l(project.submitted_at, format: :project_summary_time) : ""
  end

  def principal_investigators_list
    principal_investigators.map{ |principal_investigator| principal_investigator.user.full_name }.to_sentence
  end

  def applicant_name
    applicant.full_name
  end

  def project_involves
    involves&.to_sentence
  end

  def partial_name
    "projects/#{project_type.parameterize.underscore}_show"
  end

  def timeframe
    if project_requires_dates?
      DateRangePresenter.value(start_date: start_date, end_date: end_date)
    else
      not_applicable
    end
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

  private

  attr_reader :project

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
    end.flatten
  end
end
