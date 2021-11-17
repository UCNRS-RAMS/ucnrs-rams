# frozen_string_literal: true

class StepsPresenter
  def initialize(current_step)
    @current_step = current_step
  end

  COLOR = "#556b72"
  ACTIVE_COLOR = "#002045"
  COMPLETE_CLASS_NAME = "complete"
  ACTIVE_CLASS_NAME = "active"
  UPCOMING_CLASS_NAME = "upcoming"

  def svg(display_step)
    {
      partial: "svg/step_marker",
      locals: { presenter: svg_presenter(display_step) }
    }
  end

  def step_class(display_step)
    if display_step < current_step
      COMPLETE_CLASS_NAME
    elsif display_step == current_step
      ACTIVE_CLASS_NAME
    else
      UPCOMING_CLASS_NAME
    end
  end

  private

  def svg_presenter(display_step)
    StepMarkerPresenter.new(
      size: 24,
      number: display_step,
      **display_values(display_step)
    )
  end

  def display_values(display_step)
    if display_step < current_step
      completed_values
    elsif display_step == current_step
      active_values
    else
      upcoming_values
    end
  end

  def upcoming_values
    {
      color: COLOR,
      fill_opacity: "0",
      use_checkmark: false,
      invert: false,
    }
  end

  def active_values
    {
      color: ACTIVE_COLOR,
      fill_opacity: "1",
      use_checkmark: false,
      invert: true,
    }
  end

  def completed_values
    {
      color: COLOR,
      fill_opacity: "1",
      use_checkmark: true,
      invert: true,
    }
  end

  attr_reader :current_step
end

