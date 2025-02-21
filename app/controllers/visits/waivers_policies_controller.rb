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

      if visit_trigger_outside_hotel?
        flash[:notice] = "<p>#{ @form.visit.reserve.outside_reservation_system_text }</p>
          <p>#{ I18n.t(".visits.waivers_policies.update.outside_reservation_flash_html",
            href: @form.visit.reserve.outside_reservation_system_url) }</p>
          <meta HTTP-EQUIV='REFRESH' content='10; url=#{@form.visit.reserve.outside_reservation_system_url}'>"

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
        reserve: visit.reserve,
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

    if first_reserve_visit_on_project?
      if have_yes_answer_for?(:iacuc_flag) && visit_reserve_personnel_for(:receive_iacuc_email).present?
        send_iacuc_email!(
          visit: visit,
          personnel_email_list: visit_reserve_personnel_for(:receive_iacuc_email).map(&:email)
        )
      end

      if have_yes_answer_for?(:drone_flag) && visit_reserve_personnel_for(:receive_drone_email).present?
        send_drone_email!(
          visit: visit,
          personnel_email_list: visit_reserve_personnel_for(:receive_drone_email).map(&:email)
        )
      end

      if have_yes_answer_for?(:scuba_flag) && visit_reserve_personnel_for(:receive_scuba_email).present?
        send_scuba_email!(
          visit: visit,
          personnel_email_list: visit_reserve_personnel_for(:receive_scuba_email).map(&:email),
        )
      end
    end
  end

  def first_reserve_visit_on_project?
    Visit.where(project: visit.project, reserve: visit.reserve).where.not(id: visit).blank?
  end

  def send_iacuc_email!(visit:, personnel_email_list:)
    ManagerMailer
      .with(visit: visit, personnel_email_list: personnel_email_list)
      .iacuc_notification_email
      .deliver_now
  end

  def send_drone_email!(visit:, personnel_email_list:)
    ManagerMailer
      .with(visit: visit, personnel_email_list: personnel_email_list)
      .drone_notification_email
      .deliver_now
  end

  def send_scuba_email!(visit:, personnel_email_list:)
    ManagerMailer
      .with(visit: visit, personnel_email_list: personnel_email_list)
      .scuba_notification_email
      .deliver_now
  end

  def visit_reserve_personnel_for(email_type)
    ReservePersonnel
      .where(reserve: visit.reserve)
      .receiving_email_type(email_type)
  end

  def have_yes_answer_for?(flag_type)
    ProjectPermitAnswer
      .where(project: visit.project)
      .with_flag_type(flag_type)
      .for_answer(true)
      .present?
  end

  def visit_trigger_outside_hotel?
    visit.amenity_visits.map { |amenity_visit| amenity_visit.amenity.outside_reservation_system }.include? true
  end
end
