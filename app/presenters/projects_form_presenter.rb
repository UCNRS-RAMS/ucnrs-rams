# frozen_string_literal: true

class ProjectsFormPresenter
  def initialize(user:, current_step:, form: nil)
    @user = user
    @form = form
    @steps_presenter = StepsPresenter.new(current_step)
  end

  delegate :svg, :step_class, to: :steps_presenter

  private

  attr_reader :user, :form, :steps_presenter
end
