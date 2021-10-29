class Reserve < ApplicationRecord
  IMAGE_PLACEHOLDER = "reserve_placeholder.jpg".freeze

  has_one_attached :reserve_avatar

  belongs_to :managing_campus, class_name: "Institution", optional: true
  belongs_to :address_state, class_name: "State"
  has_many :amenities
  has_many :personnel, class_name: "ReservePersonnel"
  has_and_belongs_to_many :waivers

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

  def image_placeholder
    IMAGE_PLACEHOLDER
  end
end
