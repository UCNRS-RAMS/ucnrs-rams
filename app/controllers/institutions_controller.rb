class InstitutionsController < ApplicationController
  def index
    @page = InstitutionsIndexPresenter.new(query: query)
    render layout: false
  end

  def new
    @page = InstitutionFormPresenter.new
  end

  def create
    @form = InstitutionForm.new(create_institution_params)

    if @form.submit
      flash.now[:success] = "Institution <strong>#{@form.institution.name}</strong> successfully <span class='u-l-off'>added</span>."

      respond_to do |format|
        format.js   { render action: "created", status: :created }
        format.html { redirect_back(fallback_location: root_path) }
      end
    else
      flash.now[:error] = "Institution <strong>#{@form.institution.name}</strong> failed to be <span class='u-l-off'>added</span>."
      @page = InstitutionFormPresenter.new(@form)

      render "new", status: :unprocessable_entity
    end
  end

  private

  def query
    params[:name]
  end

  def create_institution_params
    params.require(:institution).permit(
      :name,
      :city,
      :country_id,
      :state_id,
      :institution_type,
    )
  end
end
