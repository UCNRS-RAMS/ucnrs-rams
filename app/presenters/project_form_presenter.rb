# frozen_string_literal: true

class ProjectFormPresenter
  def initialize(user:, current_step:, form: nil, project_type: nil)
    @user = user
    @project_type = project_type || :research
    @form = form || ProjectForm.new(params: { project_type: @project_type })
    @current_step = current_step
    @steps_presenter = StepsPresenter.new(@current_step)
  end

  attr_reader :form, :project_type
  delegate :svg, :step_class, to: :steps_presenter
  delegate :id, to: :form

  def able_to_edit_project_type?
    project&.incomplete?
  end

  def project_type_options
    [
      :research,
      :class,
      :meeting,
    ]
  end

  def partial_name
    "projects/#{project_type}_form"
  end

  def disciplines
    Project::DISCIPLINES
  end

  def other_discipline?(discipline)
    discipline == "Other"
  end

  def involvement_flags
    [
      :involves_mammals,
      :involves_reptiles,
      :involves_amphibians,
      :involves_fish,
      :involves_birds,
      :involves_plants_fungi_soil,
      :involves_threatened_endangered_species,
      :involves_none,
    ]
  end

  def planning_questions
    [
      :method_remove_organisms,
      :method_transfer_organisms,
      :method_study_non_native_species,
      :method_chemicals,
      :method_soil_disturbance,
      :method_long_term_structures,
    ]
  end

  def chemical_question?(planning_question)
    planning_question == :method_chemicals
  end

  def current_step_name
    [".submit.step", current_step].join("_")
  end

  private

  attr_reader :user, :steps_presenter, :current_step

  def project
    form.project
  end
end
