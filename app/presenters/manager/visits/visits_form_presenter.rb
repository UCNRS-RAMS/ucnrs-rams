class Manager::Visits::VisitsFormPresenter < VisitsFormPresenter

  def project_type_partail_path
    "manager/visits/detail/project_type"
  end

  def project_partail_path
    "manager/visits/detail/project"
  end

  def reserve_partail_path
    "manager/visits/detail/reserve"
  end

  def show_browse_reserve_link
    false
  end

  def save_partail_path
    "manager/visits/detail/save"
  end
end
