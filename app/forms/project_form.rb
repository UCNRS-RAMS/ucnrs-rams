# frozen_string_literal: true

class ProjectForm
  include ActiveModel::Model

  def model_name
    ActiveModel::Name.new(Project)
  end

  def initialize(user: User.new, params: {})
    @project = Project.where(id: params[:id]).first ||
      Project.new(project_type: :research)
    @project.applicant = user
    @project.owner = user
    assign(params)
  end

  attr_reader :project
  delegate :valid?, :validate, :errors, to: :project
  delegate_missing_to :project

  def save
    begin
      Project.transaction do
        project.save!
        project_team_membership.save!
        true
      end
    rescue ActiveRecord::RecordInvalid => e
      false
    end
  end

  def start_date
    display_date(project.start_date)
  end

  def end_date
    display_date(project.end_date)
  end

  def method_remove_organisms
    radio_value_for(:method_remove_organisms)
  end

  def method_remove_organisms=(value)
    project.method_remove_organisms = boolean_value_from(value)
  end

  def method_transfer_organisms
    radio_value_for(:method_transfer_organisms)
  end

  def method_transfer_organisms=(value)
    project.method_transfer_organisms = boolean_value_from(value)
  end

  def method_study_non_native_species
    radio_value_for(:method_study_non_native_species)
  end

  def method_study_non_native_species=(value)
    project.method_study_non_native_species = boolean_value_from(value)
  end

  def method_chemicals
    radio_value_for(:method_chemicals)
  end

  def method_chemicals=(value)
    project.method_chemicals = boolean_value_from(value)
  end

  def method_soil_disturbance
    radio_value_for(:method_soil_disturbance)
  end

  def method_soil_disturbance=(value)
    project.method_soil_disturbance = boolean_value_from(value)
  end

  def method_long_term_structures
    radio_value_for(:method_long_term_structures)
  end

  def method_long_term_structures=(value)
    project.method_long_term_structures = boolean_value_from(value)
  end

  private

  def project_team_membership
    ProjectTeamMembership.new(
      project_id: id,
      user_id: applicant.id,
      institution: applicant.institution,
      active: true,
      user_role: applicant.role,
      is_principal_investigator: true,
      can_edit_project: true,
      can_add_project_user: true,
      can_add_visit: true,
      can_receive_invoice: true,
    )
  end

  def assign(params)
    params.each do |key, value|
      self.send("#{key}=", value)
    end
  end

  def display_date(date)
    date ? I18n.l(date, format: :form_output_date) : ""
  end

  def radio_value_for(field)
    if project.send(field) == true
      "Yes"
    elsif project.send(field) == false
      "No"
    else
      nil
    end
  end

  def boolean_value_from(value)
    if value == "Yes"
      true
    elsif value == "No"
      false
    else
      nil
    end
  end
end
