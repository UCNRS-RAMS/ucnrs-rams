class Manager::ReserveInfo::RulesAndRegulationsController < Manager::ApplicationController
  before_action :authenticate_user!
  before_action :confirm_current_reserve_manager!, unless: -> { super_admin? }
  before_action :is_administrator!, only: [:update], unless: -> { super_admin? }

  layout "manager"

  def edit
    form = ReserveForm.new(reserve: current_reserve)
    @presenter = Manager::ReserveInfo::RulesAndRegulationsEditPresenter.new(
      reserve: current_reserve,
      form: form,
    )
  end

  def update
    form = ReserveForm.new(
      reserve: current_reserve,
      params: rules_and_regulations_params,
    )
    @presenter = Manager::ReserveInfo::RulesAndRegulationsEditPresenter.new(
      reserve: current_reserve,
      form: form,
    )

    if form.save
      flash.now[:notice] = "Update success."
      render :edit
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def rules_and_regulations_params
    params.require(:reserve).permit(
      :rules_url,
      :code_of_conduct_url,
      :rules_and_regulations,
      :approval_message,
      :directions
    )
  end
end
