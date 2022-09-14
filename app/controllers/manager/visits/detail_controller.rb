class Manager::Visits::DetailController < ApplicationController
  before_action :authenticate_user!
  before_action :confirm_manager!

  def edit
    @form = VisitForm.new(user: current_user, params: { id: params[:visit_id] })
    @presenter = Manager::Visits::VisitsFormPresenter.new(user: current_user, form: @form)
  end
end
