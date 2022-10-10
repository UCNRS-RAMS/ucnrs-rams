class Manager::Visits::SummaryController < ApplicationController
  before_action :authenticate_user!
  before_action :confirm_reserve_manager!

  def edit
    @form = VisitForm.new(user: current_user, params: { id: params[:visit_id] })
    @presenter = Manager::Visits::VisitsFormPresenter.new(user: current_user, form: @form)
  end

  def update
    @form = VisitForm.new(user: current_user, params: visit_params)
    @presenter = Manager::Visits::VisitsFormPresenter.new(user: current_user, form: @form)

    if @form.save
      flash.now[:notice] = I18n.t("manager.visits.summary.update.flash_message")
      render :edit
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def visit_params
    params.require(:visit).permit(
      :id,
      :report_access,
      :status,
    )
  end

  def visit
    Visit.find(visit_id)
  end

  def visit_id
    params.permit(:id).require(:id)
  end
end
