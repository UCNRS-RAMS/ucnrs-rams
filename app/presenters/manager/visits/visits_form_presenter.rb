class Manager::Visits::VisitsFormPresenter < VisitsFormPresenter
  def project_type_partial_path
    "manager/visits/detail/project_type"
  end

  def project_partial_path
    "manager/visits/detail/project"
  end

  def reserve_partial_path
    "manager/visits/detail/reserve"
  end

  def show_browse_reserve_link
    false
  end

  def save_partial_path
    "manager/visits/detail/save"
  end

  private

  def amenity_scope
    (reserve&.amenities || Amenity.none)
      .visible
      .not_disable
      .by_group_number
  end

  def wrap_amenity_in_presenter(amenity)
    Manager::Visits::AmenityPresenter.new(
      amenity,
      form: form.amenity_form(amenity.id.to_s),
      user: @user,
    )
  end
end
