class Visits::WaiversPoliciesController < ApplicationController
  before_action :authenticate_user!

  def show
    @form = VisitCompleteForm.new(params: { id: visit.id })
    @presenter = Visits::UsePolicyPresenter.new(current_user: current_user, current_step: 4, visit: visit)
  end

  def update
    @form = VisitCompleteForm.new(params: { id: visit.id })

    if visit_update_params[:policy_agreement] == "1" && @form.save
      redirect_to @form.visit
    else
      @presenter = Visits::UsePolicyPresenter.new(current_user: current_user, current_step: 4, visit: visit)
      flash.now[:alert] = I18n.t(".visits.waivers_policies.show.policy_agreement_error")
      render :show, status: :unprocessable_entity
    end
  end

  private

  def visit
    Visit.find_by(id: params[:visit_id])
  end

  def visit_update_params
    params.require(:visit).permit(:policy_agreement, :id)
  end
end
