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
end
