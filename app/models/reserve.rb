class Reserve < ApplicationRecord
  LOGO_PLACEHOLDER = "reserve_logo_placeholder.png".freeze
  LISTING_PHOTO_PLACEHOLDER = "reserve_placeholder.jpg".freeze
  LARGE_HERO_PHOTO_PLACEHOLDER = "reserve-hero-placeholder.jpg".freeze

  has_one_attached :reserve_avatar
  has_rich_text :rules_and_regulations

  mount_uploader :logo, Reserve::LogoUploader
  mount_uploader :listing_photo, Reserve::PhotoUploader
  mount_uploader :large_hero_photo, Reserve::PhotoUploader

  belongs_to :managing_campus, class_name: "Institution", optional: true
  belongs_to :address_country, class_name: "Country"
  belongs_to :billing_address_country, class_name: "Country", optional: true
  belongs_to :address_state, class_name: "State", optional: true
  belongs_to :billing_address_state, class_name: "State", optional: true
  has_many :amenities
  has_many :amenity_rate_categories
  has_many :personnel, class_name: "ReservePersonnel"
  has_and_belongs_to_many :waivers
  has_many :fundings
  has_many :reserve_questions
  has_many :addendums, class_name: "ReserveAddendum"
  has_many :reserve_permits
  has_many :permits, through: :reserve_permits
  has_many :visits

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

  def logo_placeholder
    LOGO_PLACEHOLDER
  end

  def listing_photo_placeholder
    LISTING_PHOTO_PLACEHOLDER
  end

  def large_hero_photo_placeholder
    LARGE_HERO_PHOTO_PLACEHOLDER
  end
end
