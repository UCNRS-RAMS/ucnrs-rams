class Reserves::ContactReservesController < ApplicationController
  def index
    @presenter = Reserves::ContactReservesIndexPresenter.new()
  end
end
