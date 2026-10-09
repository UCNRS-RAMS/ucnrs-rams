class Manager::Dashboard::Calendar::VisitsController < Manager::ApplicationController
  before_action :authenticate_user!
  before_action :confirm_current_reserve_manager!, unless: -> { super_admin? }

  def show
    @presenter = Manager::Dashboard::Calendar::VisitShowPresenter.new(
      visit: visit,
      kind: params[:kind],
      row_id: params[:row_id],
    )
  end

  private

  def visit
    @visit ||= Visit.by_reserve(current_reserve).find(params[:id])
  end
end
