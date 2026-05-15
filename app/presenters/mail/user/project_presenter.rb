# frozen_string_literal: true

class Mail::User::ProjectPresenter
  def initialize(project)
    @project = ProjectPresenter.new(project: project)
  end

  attr_reader :project

  delegate_missing_to :project

  def principal_investigators_list
    project_team_memberships
      .includes(:user)
      .select(&:is_principal_investigator)
      &.map { |membership| membership.user.full_name }
      &.to_sentence
  end

  def project_involves
    involves&.to_sentence
  end

  def timeframe
    if earliest_user_visit_time.present? && latest_user_visit_time.present?
      DateRangePresenter.value(
        start_date: earliest_user_visit_time.to_date,
        end_date: latest_user_visit_time.to_date,
      )
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

  private

  delegate :team_memberships, to: :project, prefix: true

  def project_requires_dates?
    start_date.present? && end_date.present?
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

  def earliest_user_visit_time
    @earliest_user_visit_time ||= project.earliest_user_visit_time
  end

  def latest_user_visit_time
    @latest_user_visit_time ||= project.latest_user_visit_time
  end

  def not_applicable
    I18n.t("not_applicable")
  end
end
