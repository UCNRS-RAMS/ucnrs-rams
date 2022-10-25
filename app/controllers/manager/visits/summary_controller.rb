class Manager::Visits::SummaryController < ApplicationController
  before_action :authenticate_user!
  before_action :confirm_manager!

  def show
    @presenter = Manager::Visits::SummaryPresenter.new(visit: visit, current_user: current_user)
  end

  def edit
    @form = VisitForm.new(user: current_user, params: { id: params[:visit_id] })
    @presenter = Manager::Visits::VisitsFormPresenter.new(user: current_user, form: @form)
  end

  def update
    @form = VisitForm.new(user: current_user, params: visit_params)

    if @form.save
      flash.now[:notice] = I18n.t("manager.visits.summary.update.flash_message")
      @presenter = Manager::VisitShowPresenter.new(visit: visit, current_user: current_user)
    else
      @presenter = Manager::Visits::VisitsFormPresenter.new(user: current_user, form: @form)
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
    params.permit(:visit_id).require(:visit_id)
  end
end
