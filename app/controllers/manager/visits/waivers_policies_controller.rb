class Manager::Visits::WaiversPoliciesController < Manager::ApplicationController
  before_action :authenticate_user!
  before_action :confirm_reserve_manager!, unless: -> { super_admin? }

  layout "manager"

  def show
    @form = VisitCompleteForm.new(params: { id: visit.id })
    @presenter = Visits::UsePolicyPresenter.new(current_user: current_user, current_step: 4, visit: visit)
  end

  def update
    @form = VisitCompleteForm.new(params: { id: visit.id })

    if visit_update_params[:policy_agreement] == "1" && @form.save
      if @form.visit.submitted_at_before_last_save.nil?
        create_log2(action: :submitted, visit: @form.visit, user: current_user)

      end

      redirect_to manager_reserve_visit_path(id: visit.id)
    else
      @presenter = Visits::UsePolicyPresenter.new(current_user: current_user, current_step: 4, visit: visit)
      flash.now[:alert] = I18n.t(".visits.waivers_policies.show.policy_agreement_error")
      render :show, status: :unprocessable_entity
    end
  end

  private

  def visit
    @visit ||= Visit.find_by(id: params[:visit_id])
  end

  def visit_update_params
    params.require(:visit).permit(:policy_agreement, :id)
  end

  def create_log2(action:, visit:, user:)
    LogForm2.create(
      params: {
        action: action,
        record: visit.project,
        record_about: visit,
        user: user,
      }
    )
  end
end
