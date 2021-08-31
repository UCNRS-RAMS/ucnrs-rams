require "rails_helper"

RSpec.describe User, type: :model do
  describe "validations" do
    it { is_expected.to validate_presence_of(:first_name) }
    it { is_expected.to validate_presence_of(:last_name) }
    it { is_expected.to validate_presence_of(:emergency_contact_full_name) }
    it { is_expected.to validate_presence_of(:emergency_contact_phone_number) }
    it { is_expected.to validate_presence_of(:phone_number) }
    it { is_expected.to validate_presence_of(:address_line_1) }
    it { is_expected.to validate_presence_of(:address_city) }
    it { is_expected.to validate_presence_of(:address_state_id) }
    it { is_expected.to validate_presence_of(:address_country_id) }
    it { is_expected.to validate_presence_of(:address_postal_code) }
    it { is_expected.to validate_presence_of(:billing_address_address_line_1) }
    it { is_expected.to validate_presence_of(:billing_address_city) }
    it { is_expected.to validate_presence_of(:billing_address_state_id) }
    it { is_expected.to validate_presence_of(:billing_address_country_id) }
    it { is_expected.to validate_presence_of(:billing_address_postal_code) }
    it { is_expected.to validate_presence_of(:terms_accepted_at) }

    describe "#password_complexity" do
      it "adds an error if the password is less than 8 characters" do
        user = build(:user, password: "Pass1")

        user.save

        expect(user).not_to be_valid
        expect(user.errors.messages[:password]).to include("Password complexity requirement not met. Length should be 8-70 characters and include: 1 uppercase character and 1 digit.")
      end

      it "adds an error if the password is greater than 70 characters" do
        user = build(:user, password: "Pass1" * 15)

        user.save

        expect(user).not_to be_valid
        expect(user.errors.messages[:password]).to include("Password complexity requirement not met. Length should be 8-70 characters and include: 1 uppercase character and 1 digit.")
      end

      it "adds an error if the password does not contain at least 1 digit" do
        user = build(:user, password: "Password")

        user.save

        expect(user).not_to be_valid
        expect(user.errors.messages[:password]).to include("Password complexity requirement not met. Length should be 8-70 characters and include: 1 uppercase character and 1 digit.")
      end

      it "adds an error if the password does not contain at least 1 capital letter" do
        user = build(:user, password: "password1")

        user.save

        expect(user).not_to be_valid
        expect(user.errors.messages[:password]).to include("Password complexity requirement not met. Length should be 8-70 characters and include: 1 uppercase character and 1 digit.")
      end

      it "does not add an error if the password criteria are met" do
        user = build(:user, password: "Password1")

        user.save

        expect(user).to be_valid
        expect(user.errors.messages[:password]).to be_empty
      end
    end
  end

  it do 
    is_expected.to define_enum_for(:role)
      .with_values(
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
      ).backed_by_column_of_type(:string)
  end

  it do 
    is_expected.to define_enum_for(:gender_identity)
      .with_values(
        male: "Male",
        female: "Female",
        non_binary: "Non-binary",
        other_gender: "Other",
        prefer_not_to_state: "Prefer not to state",
      ).backed_by_column_of_type(:string)
  end

  it do 
    is_expected.to define_enum_for(:age_range)
      .with_values(
        one_to_seventeen: "1-17",
        eighteen_to_twenty_five: "18-25",
        twenty_five_to_fifty: "25-50",
        fifty_or_older: "50 or older",
      ).backed_by_column_of_type(:string)
  end
end
