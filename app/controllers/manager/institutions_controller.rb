class Manager::InstitutionsController < ApplicationController
  before_action :authenticate_user!
  before_action :confirm_reserve_manager!
  layout "manager"

  def index
    @presenter = Manager::InstitutionsIndexPresenter.new(
      page: page_number,
      filter: filter,
    )
  end

  def edit
    form = InstitutionEditForm.new(institution: institution)
    @presenter = Manager::InstitutionEditPresenter.new(form: form)
  end

  def update
    form = InstitutionEditForm.new(institution: institution, params: institution_params)
    @presenter = Manager::InstitutionEditPresenter.new(form: form)

    if form.submit
      flash.now[:notice] = I18n.t("manager.institutions.successfully_updated", institution: institution.name).html_safe
      render :edit
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def institution
    @institution ||= Institution.find(params[:id])
  end

  def institution_params
    params.require(:institution).permit(
      :name,
      :city,
      :country_id,
      :state_id,
      :institution_type,
    )
  end

  def page_number
    params[:page]
  end

  def filter
    if params[:filter].present?
      params.require(:filter).permit(
        :institution_search,
        :institution_sort_by,
        :institution_country,
        :institution_type,
      )
    end
  end
end
