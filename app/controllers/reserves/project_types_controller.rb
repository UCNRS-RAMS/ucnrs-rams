class Reserves::ProjectTypesController < ApplicationController
  def index
    @presenter = Reserves::ProjectTypesIndexPresenter.new()
  end
end
