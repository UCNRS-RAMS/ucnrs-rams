class Reserve < ApplicationRecord
  has_one_attached :reserve_avatar

  belongs_to :managing_campus, class_name: "Institution"
  has_many :amenities

  def self.blank
    Reserve.new(id: -1, name: "", pulldown_name: "")
  end

  def self.alphabetized
    order(:pulldown_name)
  end

  def self.with_accepted_project_type(project_type)
    case project_type
    when "research" then where(research_projects_accepted: true)
    when "university_class" then where(class_projects_accepted: true)
    when "meeting_or_conference" then where(conference_projects_accepted: true)
    when "public_use" then where(public_projects_accepted: true)
    else
      none
    end
  end

  def waivers
    Waiver.fake
  end

  def image_placeholder
    "reserve_placeholder.jpg"
  end
end
