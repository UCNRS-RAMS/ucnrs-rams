
class Manager::Visits::SummaryController < ApplicationController
  before_action :authenticate_user!
  before_action :confirm_manager!

  def show
  end
end
