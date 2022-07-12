class Manager::ReserveInfo::RulesAndRegulationsController < ApplicationController
  layout "manager"
  before_action :authenticate_user!

  def edit
    form = ReserveForm.new(params: { id: current_reserve.id })
    @presenter = Manager::ReserveInfo::RulesAndRegulationsEditPresenter.new(reserve: current_reserve, form: form)
  end

  def update
    form = ReserveForm.new(params: rules_and_regulations_params.merge(id: current_reserve.id))
    @presenter = Manager::ReserveInfo::RulesAndRegulationsEditPresenter.new(reserve: current_reserve, form: form)
    if form.save
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
    )
  end
end
