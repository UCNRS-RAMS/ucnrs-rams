class VisitsController < ApplicationController
  before_action :authenticate_user!

  def new
    @visit = Visit.new
  end
end
