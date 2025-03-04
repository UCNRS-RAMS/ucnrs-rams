# frozen_string_literal: true

class Visits::ReservesPresenter
  def initialize(project_type:, reserve_id: nil, project_id: nil)
    @project_type = project_type
    @reserve_id = reserve_id
    @project_id = project_id
  end

  attr_reader :project_type, :reserve_id, :project_id

  def reserves
    [
      Reserve.blank,
      *Reserve.with_accepted_project_type(project_type || reserve_translated_project_type).alphabetized
    ]
  end

  def selected_reserve(reserve)
    if reserve.id.to_s == reserve_id.to_s
      "selected"
    else
      nil
    end
  end

  private

  def project_project_type
    Project.find_by(id: project_id)&.project_type
  end

  def reserve_translated_project_type
    case project_project_type
    when "research" then "research"
    when "class" then "university_class"
    when "meeting" then "meeting_or_conference"
    when "public_use" then "public_use"
    when "housing" then "housing"
    end
  end
end
