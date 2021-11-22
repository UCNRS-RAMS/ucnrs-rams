# frozen_string_literal: true

class ProjectsNewPresenter
  def initialize(user:, current_step:, form: nil, project_type: nil)
    @user = user
    @form = form || ProjectForm.new
    @project_type = project_type || :research
    @steps_presenter = StepsPresenter.new(current_step)
  end

  attr_reader :form, :project_type
  delegate :svg, :step_class, to: :steps_presenter

  def project_type_options
    [
      :research,
      :university_class,
      :meeting_or_conference,
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

  private

  attr_reader :user, :steps_presenter
end
