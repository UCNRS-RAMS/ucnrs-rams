class Reserve < ApplicationRecord
  LOGO_PLACEHOLDER = "ucnature-logo.png".freeze
  LISTING_PHOTO_PLACEHOLDER = "reserve_placeholder.jpg".freeze
  LARGE_HERO_PHOTO_PLACEHOLDER = "reserve-hero-placeholder.jpg".freeze

  has_one_attached :reserve_avatar
  has_rich_text :rules_and_regulations
  has_rich_text :directions

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
  has_many :reserve_tags, dependent: :destroy

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
    when "housing" then where(housing_projects_accepted: true)
    else
      none
    end
  end

  def self.searching_term(search_filter)
    if search_filter.present?
      sanitized = "%#{sanitize_sql_like(search_filter)}%"
      left_outer_joins(:address_country, :address_state)
        .where(
          <<-end_sql.squish,
          reserves.name LIKE ? OR
          reserves.short_name LIKE ? OR
          reserves.pulldown_name LIKE ? OR
          reserves.rules LIKE ? OR
          reserves.rates LIKE ? OR
          reserves.department LIKE ? OR
          reserves.address_line_1 LIKE ? OR
          reserves.address_line_2 LIKE ? OR
          reserves.address_city LIKE ? OR
          states.name LIKE ? OR
          reserves.address_postal_code LIKE ? OR
          countries.name LIKE ? OR
          reserves.home_page_url LIKE ? OR
          reserves.special_needs_statement LIKE ? OR
          reserves.doi LIKE ? OR
          reserves.administrative_group_name LIKE ? OR
          reserves.administrative_group_name_acronym LIKE ? OR
          reserves.administrative_group_state LIKE ?
          end_sql
          *Array.new(18, sanitized)
        )
    else
      all
    end
  end

  def self.with_names(tag_names)
    if tag_names.present?
      where(id: reserve_ids_with_tag_names(tag_names))
    else
      all
    end
  end

  def logo_exists?
    logo_url.present?
  end

  def logo_src(size = :medium)
    logo_exists? ? logo_url(size) : LOGO_PLACEHOLDER
  end

  def listing_photo_exists?
    listing_photo_url.present?
  end

  def listing_photo_src(size = :medium)
    listing_photo_exists? ? listing_photo_url(size) : LISTING_PHOTO_PLACEHOLDER
  end

  def large_hero_photo_exists?
    large_hero_photo_url.present?
  end

  def large_hero_photo_src(size = :medium)
    large_hero_photo_exists? ? large_hero_photo_url(size) : LARGE_HERO_PHOTO_PLACEHOLDER
  end

  def self.reserve_ids_with_tag_names(tag_names)
    tag_names
      .reduce(with_name(tag_names.pop)) { |reserves, tag_name| reserves & with_name(tag_name) }
      .pluck(:id)
  end

  def self.with_name(tag_name)
    if tag_name.present?
      joins(:reserve_tags).where(reserve_tags: { name: tag_name }).distinct
    else
      all
    end
  end
end
