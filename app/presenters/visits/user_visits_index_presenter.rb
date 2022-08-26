# frozen_string_literal: true

class Visits::UserVisitsIndexPresenter
  include Rails.application.routes.url_helpers

  def initialize(current_step:, current_user:, visit:)
    @visit = visit
    @current_step = current_step
    @current_user = current_user
    @steps_presenter = StepsPresenter.new(@current_step)
    @form_presenter = initialize_form_presenter
  end

  attr_reader :visit, :form_presenter, :steps_presenter, :current_step, :current_user

  delegate :svg, :step_class, to: :steps_presenter
  delegate :reserve_name, to: :visit, prefix: true

  delegate_missing_to :form_presenter

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

  def initialize_form_presenter
    form = UserVisitForm.new(params: { visit_id: visit.id })
    Visits::UserVisitFormPresenter.new(
      current_user: current_user,
      add_visitor_partial: "team_members",
      show_add_guest_modal: false,
      form: form,
    )
  end
end
