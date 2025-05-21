class Manager::Visits::SummaryController < Manager::ApplicationController
  before_action :authenticate_user!
  before_action :confirm_manager!, unless: -> { super_admin? }
  before_action :is_administrator_or_accountant!, only: [:update], unless: -> { super_admin? }

  layout "manager"

  def show
    @presenter = Manager::Visits::SummaryPresenter.new(visit: visit, current_user: current_user)
  end

  def edit
    @form = VisitForm.new(user: current_user, params: { id: params[:visit_id] })
    @presenter = Manager::Visits::VisitsFormPresenter.new(user: current_user, form: @form)
  end

  def update
    @form = VisitForm.new(user: current_user, params: visit_params)

    if @form.update_status
      flash.now[:notice] = I18n.t("manager.visits.summary.update.flash_message")
      create_log2(action: :updated, visit: @form.visit, user: current_user)
      @presenter = Manager::VisitShowPresenter.new(visit: visit, current_user: current_user)

      if email_params[:email_notification_method] == "composed_email"
        send_update_email!(visit: @form.visit, email_params: email_params)
      end

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

  def email_params
    params.require(:visit).permit(
      :email_notification_method,
      :approval_message,
      :bcc_personnel,
      email_to_list: [],
    )
  end

  def visit
    Visit.find(visit_id)
  end

  def visit_id
    params.permit(:visit_id).require(:visit_id)
  end

  def send_update_email!(visit:, email_params:)
    UserMailer
      .with(
        visit: visit,
        approval_message: email_params[:approval_message],
        email_to_list: email_params[:email_to_list],
        bcc_personnel: ActiveModel::Type::Boolean.new.cast(email_params[:bcc_personnel]),
      )
      .visit_update
      .deliver_now
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
