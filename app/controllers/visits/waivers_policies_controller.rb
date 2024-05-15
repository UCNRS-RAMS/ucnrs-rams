class Visits::WaiversPoliciesController < ApplicationController
  before_action :authenticate_user!

  def show
    @form = VisitCompleteForm.new(params: { id: visit.id })
    @presenter = Visits::UsePolicyPresenter.new(current_user: current_user, current_step: 4, visit: visit)
  end

  def update
    @form = VisitCompleteForm.new(params: { id: visit.id })

    if visit_update_params[:policy_agreement] == "1" && @form.save
      if @form.visit.submitted_at_before_last_save.nil?
        create_log2(action: :submitted, visit: @form.visit, user: current_user)
        send_emails!(visit: @form.visit)
      end

      redirect_to @form.visit
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

  def send_emails!(visit:)
    ManagerMailer
      .with(presenter: Mail::Manager::VisitNewPresenter.new(visit))
      .visit_new
      .deliver_now

    UserMailer
      .with(presenter: Mail::User::VisitNewPresenter.new(visit))
      .visit_new
      .deliver_now

    if visit.project.have_yes_iacuc_answer? && visit_reserve_receiving_iacuc_personnel_email_list.present?
      send_iacuc_email!(visit: visit)
    end
  end

  def send_iacuc_email!(visit:)
    ManagerMailer
      .with(visit: visit, personnel_email_list: visit_reserve_receiving_iacuc_personnel_email_list)
      .iacuc_notification_email
      .deliver_now
  end

  def visit_reserve_receiving_iacuc_personnel_email_list
    visit
      .reserve
      .personnel
      .receiving_iacuc_email
      .map(&:email)
  end
end
