# frozen_string_literal: true

class Manager::Users::ActivitiesIndexPresenter
  DEFAULT_LIMIT_FOR_INDEX = 6

  def initialize(user: nil, visits_page: 1, projects_page: 1, invoices_page: 1)
    @user = user
    @visits_page = visits_page
    @projects_page = projects_page
    @invoices_page = invoices_page
  end

  delegate_missing_to :user

  delegate :id, :full_name, :institution, to: :user, prefix: true
  delegate :name, to: :user_institution, prefix: true
  delegate :institution_type, to: :user_institution

  def user
    UserPresenter.new(@user)
  end

  def reserve_manager?(reserve)
    user.admin_or_manage_reserve?(reserve)
  end

  def visits
    visit_scope.map do |visit|
      VisitPresenter.new(visit)
    end
  end

  def visit_scope
    Visit
      .visit_requests_for_user(user)
      .ordered_by_visit_date
      .page(@visits_page)
      .per(DEFAULT_LIMIT_FOR_INDEX)
      .includes([:reserve])
  end

  def projects
    project_scope.map do |project|
      ProjectPresenter.new(project: project)
    end
  end

  def project_scope
    Project
      .with_active_team_member(user: user)
      .ordered_by_visit_date
      .page(@projects_page)
      .per(DEFAULT_LIMIT_FOR_INDEX)
      .includes([:applicant])
  end

  def invoices
    invoice_scope.map do |invoice|
      InvoicePresenter.new(invoice)
    end
  end

  def invoice_scope
    user.invoices
      .recent_first
      .page(@invoices_page)
      .per(DEFAULT_LIMIT_FOR_INDEX)
      .includes([{ visit: :reserve }])
  end
end
