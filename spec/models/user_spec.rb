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
    it { is_expected.to validate_presence_of(:address_postal_code) }
    it { is_expected.to validate_presence_of(:terms_accepted_at) }
    it { is_expected.to validate_presence_of(:institution) }

    describe "#password_complexity" do
      let!(:country) { create(:country, name: "United States") }
      let!(:state) { create(:state, name: "California", country: country) }

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

    describe "#required_for_address_country?" do
      context "when the address_state exists" do
        context "when the address_state is not associated with the address_country" do
          it "adds an error message" do
            country = create(:country, name: "Country")
            other_country = create(:country, name: "Other Country")
            state = create(:state, country: other_country)
            user = build(:user, address_country: country, address_state: state)
  
            user.save
  
            expect(user).not_to be_valid
            expect(user.errors.messages[:address_state_id]).to include("must exist as a state, province, or territory of the address country")
          end
        end

        context "when the address_state is associated with the address_country" do
          it "does not add an error message" do
            country = create(:country, name: "Country")
            state = create(:state, country: country)
            user = build(:user, address_country: country, address_state: state)
  
            user.save
  
            expect(user).to be_valid
            expect(user.errors.messages[:address_state_id]).to be_empty
          end
        end
      end

      context "when the address_state does not exist" do
        context "when the address_country does not have states" do
          it "does not add an error message" do
            country = create(:country, name: "Country")
            user = build(:user, address_country: country, address_state: nil)
  
            user.save
  
            expect(user).to be_valid
            expect(user.errors.messages[:address_state_id]).to be_empty
          end
        end

        context "when the address_country does have states" do
          it "adds an error message" do
            country = create(:country, name: "Country")
            state = create(:state, country: country)
            user = build(:user, address_country: country, address_state: nil)

            user.save

            expect(user).not_to be_valid
            expect(user.errors.messages[:address_state_id]).to include("must exist as a state, province, or territory of the address country")
          end
        end
      end
    end

    describe "#required_for_billing_address_country?" do
      context "when the billing_address_state exists" do
        context "when the billing_address_state is not associated with the billing_address_country" do
          it "adds an error message" do
            country = create(:country, name: "Country")
            other_country = create(:country, name: "Other Country")
            state = create(:state, country: other_country)
            user = build(:user, billing_address_country: country, billing_address_state: state)
  
            user.save
  
            expect(user).not_to be_valid
            expect(user.errors.messages[:billing_address_state_id]).to include("must exist as a state, province, or territory of the billing address country")
          end
        end

        context "when the billing_address_state is associated with the billing_address_country" do
          it "does not add an error message" do
            country = create(:country, name: "Country")
            state = create(:state, country: country)
            user = build(:user, billing_address_country: country, billing_address_state: state)
  
            user.save
  
            expect(user).to be_valid
            expect(user.errors.messages[:billing_address_state_id]).to be_empty
          end
        end
      end

      context "when the billing_address_state does not exist" do
        context "when the billing_address_country does not have states" do
          it "does not add an error message" do
            country = create(:country, name: "Country")
            user = build(:user, billing_address_country: country, billing_address_state: nil)
  
            user.save
  
            expect(user).to be_valid
            expect(user.errors.messages[:billing_address_state_id]).to be_empty
          end
        end

        context "when the billing_address_country does have states" do
          it "adds an error message" do
            country = create(:country, name: "Country")
            _state = create(:state, country: country)
            user = build(:user, billing_address_country: country, billing_address_state: nil)

            user.save

            expect(user).not_to be_valid
            expect(user.errors.messages[:billing_address_state_id]).to include("must exist as a state, province, or territory of the billing address country")
          end
        end
      end
    end
  end

  describe "associations" do
    it { is_expected.to belong_to(:institution) }
    it { is_expected.to belong_to(:address_country).class_name("Country") }
    it { is_expected.to belong_to(:billing_address_country).class_name("Country").optional(true) }
    it { is_expected.to belong_to(:address_state).class_name("State").optional(true) }
    it { is_expected.to belong_to(:billing_address_state).class_name("State").optional(true) }
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
