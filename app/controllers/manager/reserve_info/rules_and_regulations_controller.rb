class Manager::ReserveInfo::RulesAndRegulationsController < ApplicationController
  layout "manager"
  before_action :authenticate_user!

  def index
    @presenter = Manager::ReserveInfo::RulesAndRegulationsIndexPresenter.new(
      reserve: current_reserve,
    )
  end

  private

end
