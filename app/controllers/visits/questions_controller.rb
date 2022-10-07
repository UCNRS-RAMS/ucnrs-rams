class Visits::QuestionsController < ApplicationController
  before_action :authenticate_user!

  def index
    @presenter = Visits::QuestionsIndexPresenter.new(
      current_step: 3,
      visit: visit,
    )
  end

  private

  def visit
    @visit ||= Visit.find(params[:visit_id])
  end
end
