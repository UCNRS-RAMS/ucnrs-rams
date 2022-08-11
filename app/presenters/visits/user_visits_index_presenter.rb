# frozen_string_literal: true

class Visits::UserVisitsIndexPresenter
  include Rails.application.routes.url_helpers

  def initialize(current_step:, visit:, add_visitor_partial: nil, current_user: nil)
    @visit = visit
    @current_step = current_step
    @steps_presenter = StepsPresenter.new(@current_step)
    @add_visitor_partial = add_visitor_partial || "team_member"
    @current_user = current_user
  end

  attr_reader :current_user, :visit, :add_visitor_partial

  delegate :svg, :step_class, to: :steps_presenter
  delegate :reserve_name, to: :visit, prefix: true

  def user_visits
    visit.user_visits.includes([:user, :institution])
      .map do |user_visit|
      Visits::UserVisitPresenter.new(
        user_visit,
      )
    end
  end

  def visit_date_range
    DateRangePresenter.value(start_date: visit.start_date, end_date: visit.end_date)
  end


  def new_user_visit_path(partial_name)
    new_visit_user_visit_path(visit.id, add_visitor_partial: partial_name)
  end

  def user_role_options
    User.roles.except(:no_selection).map { |key, value| [value, key] }
  end

  def add_visitor_link_class(partial_name)
    partial_name == add_visitor_partial ? "selected" : ""
  end

  def add_visitor_partial_path
    "visits/user_visits/#{add_visitor_partial}"
  end

  private

  attr_reader :steps_presenter, :current_step
end
