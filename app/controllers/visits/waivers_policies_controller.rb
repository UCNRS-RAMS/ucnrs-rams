class Visits::WaiversPoliciesController < ApplicationController
  before_action :authenticate_user!

  def show
    @form = VisitCompleteForm.new(params: { id: visit.id })
    @presenter = Visits::UsePolicyPresenter.new(current_user: current_user, current_step: 4, visit: visit)
  end

  def update
    @form = VisitCompleteForm.new(params: { id: visit.id })

    if visit_update_params[:policy_agreement] == "1" && @form.save
      create_log(action: :updated, visit: @form.visit, project: @form.project) if @form.status == "approved"
      send_email!(visit: @form.visit) if @form.visit.submitted_at_before_last_save.nil?
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

  def create_log(action:, visit:, project:)
    LogForm.create(params: {
        action: action,
        user_id: current_user.id,
      },
      record: visit,
      record_about: project
    )
  end

  def send_email!(visit:)
    ManagerMailer
      .with(presenter: Mail::Manager::VisitNewPresenter.new(visit))
      .visit_new
      .deliver_now

    UserMailer
      .with(presenter: Mail::User::VisitNewPresenter.new(visit))
      .visit_new
      .deliver_now
  end
end
