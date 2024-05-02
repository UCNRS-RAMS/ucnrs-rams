class Manager::ReserveInfo::AmenitiesAndRates::AmenityRatesController < Manager::ApplicationController
  before_action :authenticate_user!
  before_action :confirm_current_reserve_manager!, unless: -> { super_admin? }
  before_action :is_administrator!, only: [:edit, :update], unless: -> { super_admin? }

  layout "manager"

  def edit
    form = AmenityRatesForm.new(amenity: amenity)
    @presenter =
      Manager::ReserveInfo::AmenitiesAndRates::AmenityRatesEditPresenter.new(form: form)
  end

  def update
    form = AmenityRatesForm.new(
      amenity: current_reserve.amenities.find(params[:id]),
      params: amenity_rates_params,
    )

    if form.save
      redirect_to manager_reserve_reserve_info_amenities_and_rates_path(current_reserve)
    else
      @presenter =
        Manager::ReserveInfo::AmenitiesAndRates::AmenityRatesEditPresenter.new(form: form)
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def amenity
    @amenity ||= current_reserve
      .amenities
      .includes(amenity_rates: :amenity_rate_category)
      .find(params[:id])
  end

  def amenity_rates_params
    params.require(:amenity).permit(
      :id,
      amenity_rates_attributes: [
        :id,
        :rate,
      ]
    )
  end
end
