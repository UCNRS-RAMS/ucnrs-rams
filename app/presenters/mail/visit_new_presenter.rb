# frozen_string_literal: true

class Mail::VisitNewPresenter
  def initialize(visit)
    @visit = VisitShowPresenter.new(visit)
  end

  attr_reader :visit

  delegate_missing_to :visit

  def visit_applicant_name
    applicant_name
  end

  def visit_applicant_email
    user.email
  end

  def visit_reserve
    ReservePresenter.new(visit.reserve)
  end

  def visit_project
    ProjectShowPresenter.new(visit.project)
  end
end
