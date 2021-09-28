class InstitutionsController < ApplicationController
  def index
    @page = InstitutionsIndexPresenter.new(query: query)
    render layout: false
  end

  private

  def query
    params[:name]
  end
end
