# frozen_string_literal: true

class User < ApplicationRecord
  VALID_PASSWORD_PATTERN = /^(?=.*?[A-Z])(?=.*?[0-9]).{8,70}$/

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
    :billing_address_state,
    :billing_address_country,
    :billing_address_postal_code do |record, attr, value|
    billing_address_values = [
      record[:billing_address_line_1],
      record[:billing_address_city],
      record[:billing_address_state],
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
  has_many :project_team_memberships, class_name: "ProjectTeamMember"

  enum gender_identity: {
    male: "Male",
    female: "Female",
    non_binary: "Non-binary",
    other_gender: "Other",
    prefer_not_to_state: "Prefer not to state",
  }

  enum role: {
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
    staff: "Staff",
  }

  enum age_range: {
    one_to_seventeen: "1-17",
    eighteen_to_twenty_five: "18-25",
    twenty_five_to_fifty: "25-50",
    fifty_or_older: "50 or older",
  }

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
