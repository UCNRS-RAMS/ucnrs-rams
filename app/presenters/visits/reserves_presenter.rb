class Visits::ReservesPresenter
  def initialize(project_type:, reserve_id: nil)
    @project_type = project_type
    @reserve_id = reserve_id
  end

  attr_reader :project_type, :reserve_id

  def reserves
    [
      Reserve.blank,
      *Reserve.with_accepted_project_type(project_type).alphabetized
    ]
  end

  def selected_reserve(reserve)
    if reserve.id.to_s == reserve_id.to_s
      "selected"
    else
      nil
    end
  end
end
