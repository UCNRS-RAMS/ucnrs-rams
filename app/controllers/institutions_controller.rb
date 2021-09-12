class InstitutionsController < ApplicationController
  def index
    @institutions = Institution
      .with_name_like(query)
      .limit(Institution::DEFAULT_LIMIT_FOR_INDEX)

    render json: @institutions
  end

  private

  def query
    params[:name]
  end
end
