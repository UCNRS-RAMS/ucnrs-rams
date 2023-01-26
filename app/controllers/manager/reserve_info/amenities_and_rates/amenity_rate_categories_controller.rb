class Manager::ReserveInfo::AmenitiesAndRates::AmenityRateCategoriesController < Manager::ManagerController
  layout "manager"
  before_action :authenticate_user!
  before_action :confirm_reserve_manager!
  before_action :is_administrator!, only: [:update]

  def edit
    form = AmenityRateCategoryForm.new(amenity_rate_category: amenity_rate_category)
    @presenter = Manager::ReserveInfo::AmenitiesAndRates::AmenityRateCategoryEditPresenter.new(form: form)
  end

  def update
    form = AmenityRateCategoryForm.new(amenity_rate_category: amenity_rate_category, params: amenity_rate_category_params)
    
    if form.save
      redirect_to manager_reserve_reserve_info_amenities_and_rates_path(current_reserve)
    else
      @presenter = Manager::ReserveInfo::AmenitiesAndRates::AmenityRateCategoryEditPresenter.new(form: form)
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def amenity_rate_category
    @amenity_rate_category ||= current_reserve.amenity_rate_categories.find(params[:id])
  end

  def amenity_rate_category_params
    params.require(:amenity_rate_category).permit(
      :id,
      :reserve_id,
      :description,
      :sort_order,
      :visible,
      :state_university,
      :state_college,
      :community_college,
      :other_state_institution,
      :outside_state,
      :international,
      :K12,
      :nongovernmental,
      :governmental,
      :business,
      :other,
    )
  end
end
