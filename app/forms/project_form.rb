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
    @project.attributes = params
  end

  attr_reader :project
  delegate :valid?, :validate, :errors, :save, to: :project
  delegate_missing_to :project

  def start_date
    display_date(project.start_date)
  end

  def end_date
    display_date(project.end_date)
  end

  def start_date=(date)
    project.start_date = parse_date(date)
  end

  def end_date=(date)
    project.end_date = parse_date(date)
  end

  def method_remove_organisms
    radio_value_for(:method_remove_organisms)
  end

  def method_transfer_organisms
    radio_value_for(:method_transfer_organisms)
  end

  def method_study_non_native_species
    radio_value_for(:method_study_non_native_species)
  end

  def method_chemicals
    radio_value_for(:method_chemicals)
  end

  def method_soil_disturbance
    radio_value_for(:method_soil_disturbance)
  end

  def method_long_term_structures
    radio_value_for(:method_long_term_structures)
  end

  private

  def display_date(date)
    date ? I18n.l(date, format: :form_output_date) : ""
  end

  def parse_date(date_string)
    begin
      Time.strptime(
        date_string,
        I18n.translate("date.formats.form_input_date"),
      )
    rescue ArgumentError, TypeError
      nil
    end
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
end
