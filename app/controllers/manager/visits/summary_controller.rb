class Manager::Visits::SummaryController < ApplicationController
  before_action :authenticate_user!
  before_action :confirm_reserve_manager!

  def show; end
end
