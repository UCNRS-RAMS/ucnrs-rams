# frozen_string_literal: true

class User < ApplicationRecord
  VALID_PASSWORD_PATTERN = /^(?=.*?[A-Z])(?=.*?[0-9]).{8,70}$/

  UCNRS_STREET_ADDRESS = "1111 Franklin Street"
  UCNRS_CITY = "Oakland"
  UCNRS_POSTAL_CODE = "94607"
  FAKE_PHONE_NUMBER = "111-111-1111"
  FAKE_EMERGENCY_CONTACT = "UCNRS Emergency Contact"
  FAKE_EMERGENCY_CONTACT_PHONE_NUMBER = "222-222-2222"

  devise :confirmable,
    :database_authenticatable,
    :registerable,
    :recoverable,
    :rememberable,
    :validatable

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :role, presence: true
  validates :emergency_contact_full_name, presence: true
  validates :emergency_contact_phone_number, presence: true
  validates :phone_number, presence: true
  validates :address_line_1, presence: true
  validates :address_city, presence: true
  validates :address_state, presence: true, if: :required_for_address_country?
  validates :address_postal_code, presence: true
  validates :billing_address_state, presence: true, if: :required_for_billing_address_country?
  validates :terms_accepted_at, presence: true
  validates :institution, presence: true

  validate :password_complexity

  validates_each :billing_address_line_1,
    :billing_address_city,
    :billing_address_country,
    :billing_address_postal_code do |record, attr, value|
      billing_address_values = [
        record[:billing_address_line_1],
        record[:billing_address_city],
        record[:billing_address_country],
        record[:billing_address_postal_code],
      ].reject { |billing_address_value| billing_address_value.blank? }

      if value.blank? && billing_address_values.any?
        record.errors.add(attr, :billing_address_fields_presence)
      end
    end

  belongs_to :institution
  belongs_to :address_country, class_name: "Country"
  belongs_to :billing_address_country, class_name: "Country", optional: true
  belongs_to :address_state, class_name: "State", optional: true
  belongs_to :billing_address_state, class_name: "State", optional: true
  has_many :project_team_memberships, class_name: "ProjectTeamMembership"
  has_many :projects, through: :project_team_memberships, class_name: "Project"
  has_many :reserve_personnel
  has_many :managed_reserves, through: :reserve_personnel, source: :reserve
  has_many :user_visits
  has_many :logs
  has_many :invoice_recipients
  has_many :invoice_payments
  has_many :invoices, through: :invoice_recipients

  def institution_name
    read_attribute(:institution_name) || institution.name
  end

  enum :gender_identity, {
    male: "Male",
    female: "Female",
    non_binary: "Non-binary",
    other_gender: "Other",
    prefer_not_to_state: "Prefer not to state",
  }

  enum :role, {
    no_selection: "No selection",
    faculty: "Faculty",
    research_scientist: "Research Scientist/Post Doc",
    research_assistant: "Research Assistant (non-student/faculty/postdoc)",
    graduate_student: "Graduate Student",
    undergraduate_student: "Undergraduate Student",
    k_12_instructor: "K-12 Instructor",
    k_12_student: "K-12 Student",
    professional: "Professional",
    other: "Other",
    docent: "Docent",
    volunteer: "Volunteer",
    reserve_staff: "Staff",
  }

  enum :age_range, {
    one_to_seventeen: "1-17",
    eighteen_to_twenty_five: "18-25",
    twenty_five_to_fifty: "25-50",
    fifty_or_older: "50 or older",
  }

  def self.placeholder_data_for_non_registered_users
    default_country = Country.where(name: "United States").first_or_create
    default_state = State.where(name: "California", country: default_country).first_or_create

    {
      password: SecureRandom.urlsafe_base64(10) + "1!",
      terms_accepted_at: Time.current,
    }
  end

  def self.search(query, limit: 30)
    URI
      .decode_www_form_component(query)
      .strip
      .split
      .inject(self) do |scope, part|
        scope.where(
          "first_name REGEXP :query OR last_name REGEXP :query OR email REGEXP :query",
          query: part
        )
      end
      .joins(:institution)
      .select(arel_table[Arel.star], Institution.arel_table[:name].as("institution_name"))
      .includes([:institution])
      .limit(limit)
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def initials
    "#{first_name[0,1]} #{last_name[0,1]}"
  end

  def able_to_edit?(project)
    project_team_memberships
      .where(project: project, active: true)
      .first
      &.can_edit_project
  end

  def able_to_add_user?(project)
    project_team_memberships
      .where(project: project, active: true)
      .first
      &.can_add_project_user
  end

  def manager_of_reserve?(reserve)
    managed_reserve_ids.include?(reserve&.id)
  end

  def admin_or_manage_reserve?(reserve)
    admin? || manager_of_reserve?(reserve)
  end

  def is_manager?
    managed_reserve_ids.present?
  end

  def self.non_group_users
    where.not(id: 1)
  end

  def self.with_role(role)
    if role.present?
      where(role: role)
    else
      all
    end
  end

  def self.search_institution(query)
    joins(:institution)
      .merge(Institution.search(query))
  end

  def self.with_institution_type(institution_type)
    joins(:institution)
      .merge(Institution.with_institution_type(institution_type))
  end

  def self.sort_using(sort_option = nil)
    case sort_option.to_s
    when "user_id" then order(id: :desc)
    when "last_name" then order(:last_name)
    when "created_at" then order(created_at: :desc)
    else
      all
    end
  end

  private

  def password_complexity
    return if password.blank? || password =~ VALID_PASSWORD_PATTERN
    errors.add(:password, :complexity)
  end

  def required_for_address_country?
    if address_state.present?
      if !address_state.in_country?(address_country)
        errors.add(:address_state_id, :must_be_in_country)
      end
    elsif address_country.present? && address_country.has_states?
      errors.add(:address_state_id, :must_be_in_country)
    end
  end

  def required_for_billing_address_country?
    if billing_address_state.present?
      if billing_address_country.present? && !billing_address_state.in_country?(billing_address_country)
        errors.add(:billing_address_state_id, :must_be_in_country)
      end
    elsif billing_address_country.present? && billing_address_country.has_states?
      errors.add(:billing_address_state_id, :must_be_in_country)
    end
  end
end
