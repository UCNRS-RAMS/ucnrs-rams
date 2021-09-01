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
  validates :address_state, presence: true
  validates :address_postal_code, presence: true
  validates :terms_accepted_at, presence: true
  validates :institution, presence: true

  validate :password_complexity

  belongs_to :institution
  belongs_to :address_country, class_name: "Country"
  belongs_to :billing_address_country, class_name: "Country", optional: true
  belongs_to :address_state, class_name: "State"
  belongs_to :billing_address_state, class_name: "State", optional: true

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
end
