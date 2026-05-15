require "rails_helper"

RSpec.describe User, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:institution) }
    it { is_expected.to belong_to(:address_country).class_name("Country") }
    it { is_expected.to belong_to(:billing_address_country).class_name("Country").optional(true) }
    it { is_expected.to belong_to(:address_state).class_name("State").optional(true) }
    it { is_expected.to belong_to(:billing_address_state).class_name("State").optional(true) }
    it { is_expected.to have_many(:project_team_memberships).class_name("ProjectTeamMembership") }
    it { is_expected.to have_many(:reserve_personnel) }
    it { is_expected.to have_many(:managed_reserves).through(:reserve_personnel) }
    it { is_expected.to have_many(:invoice_recipients) }
    it { is_expected.to have_many(:invoice_payments) }
    it { is_expected.to have_many(:invoices).through(:invoice_recipients) }
  end

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

    describe "validating billing_address_fields" do
      it "does not add an error if no billing_address_fields are present" do
        user = build(:user,
          billing_address_line_1: nil,
          billing_address_city: nil,
          billing_address_state: nil,
          billing_address_country: nil,
          billing_address_postal_code: nil,
        )

        user.save

        expect(user).to be_valid
        expect(user.errors.messages).to be_blank
      end

      describe "#billing_address_line_1" do
        context "when the other billing_address fields are complete" do
          it "adds an error if billing_address_line_1 is not present" do
            country = create(:country)
            state = create(:state, country: country)
            user = build(:user,
              billing_address_line_1: nil,
              billing_address_city: "Some city",
              billing_address_state: state,
              billing_address_country: country,
              billing_address_postal_code: "11111",
            )

            user.save

            expect(user).not_to be_valid
            expect(user.errors.messages[:billing_address_line_1]).to include("can't be blank if including a billing address")
          end
        end

        context "when the other billing_address fields are not complete" do
          it "does not add an error if billing_address_line_1 is present" do
            user = build(:user,
              billing_address_line_1: "123 Main St.",
              billing_address_city: nil,
              billing_address_state: nil,
              billing_address_country: nil,
              billing_address_postal_code: nil,
            )

            user.save

            expect(user.errors.messages[:billing_address_line_1]).to be_blank
          end
        end
      end

      describe "#billing_address_city" do
        context "when the other billing_address fields are complete" do
          it "adds an error if billing_address_city is not present" do
            country = create(:country)
            state = create(:state, country: country)
            user = build(:user,
              billing_address_line_1: "123 Main St",
              billing_address_city: nil,
              billing_address_state: state,
              billing_address_country: country,
              billing_address_postal_code: "11111",
            )

            user.save

            expect(user).not_to be_valid
            expect(user.errors.messages[:billing_address_city]).to include("can't be blank if including a billing address")
          end
        end

        context "when the other billing_address fields are not complete" do
          it "does not add an error if billing_address_city is present" do
            user = build(:user,
              billing_address_line_1: nil,
              billing_address_city: "Some city",
              billing_address_state: nil,
              billing_address_country: nil,
              billing_address_postal_code: nil,
            )

            user.save

            expect(user.errors.messages[:billing_address_city]).to be_blank
          end
        end
      end

      describe "#billing_address_state" do
        context "when the other billing_address fields are not complete" do
          it "does not add an error if billing_address_state is present" do
            country = create(:country)
            state = create(:state, country: country)
            user = build(:user,
              billing_address_line_1: nil,
              billing_address_city: nil,
              billing_address_state: state,
              billing_address_country: nil,
              billing_address_postal_code: nil,
            )

            user.save

            expect(user.errors.messages[:billing_address_state]).to be_blank
          end
        end
      end

      describe "#billing_address_country" do
        context "when the other billing_address fields are complete" do
          it "adds an error if billing_address_country is not present" do
            country = create(:country)
            state = create(:state, country: country)
            user = build(:user,
              billing_address_line_1: "123 Main St",
              billing_address_city: "Some city",
              billing_address_state: state,
              billing_address_country: nil,
              billing_address_postal_code: "11111",
            )

            user.save

            expect(user).not_to be_valid
            expect(user.errors.messages[:billing_address_country]).to include("can't be blank if including a billing address")
          end
        end

        context "when the other billing_address fields are not complete" do
          it "does not add an error if billing_address_country is present" do
            country = create(:country)
            state = create(:state, country: country)
            user = build(:user,
              billing_address_line_1: nil,
              billing_address_city: nil,
              billing_address_state: nil,
              billing_address_country: country,
              billing_address_postal_code: nil,
            )

            user.save

            expect(user.errors.messages[:billing_address_country]).to be_blank
          end
        end
      end

      describe "#billing_address_postal_code" do
        context "when the other billing_address fields are complete" do
          it "adds an error if billing_address_postal_code is not present" do
            country = create(:country)
            state = create(:state, country: country)
            user = build(:user,
              billing_address_line_1: "123 Main St",
              billing_address_city: "Some city",
              billing_address_state: state,
              billing_address_country: country,
              billing_address_postal_code: nil,
            )

            user.save

            expect(user).not_to be_valid
            expect(user.errors.messages[:billing_address_postal_code]).to include("can't be blank if including a billing address")
          end
        end

        context "when the other billing_address fields are not complete" do
          it "does not add an error if billing_address_postal_code is present" do
            user = build(:user,
              billing_address_line_1: nil,
              billing_address_city: nil,
              billing_address_state: nil,
              billing_address_country: nil,
              billing_address_postal_code: "11111",
            )

            user.save

            expect(user.errors.messages[:billing_address_postal_code]).to be_blank
          end
        end
      end
    end
  end

  describe "delegations" do
    it { is_expected.to delegate_method(:name).to(:institution).with_prefix }
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
        reserve_staff: "Staff",
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

  describe "#full_name" do
    it "return first_name and last_name of user" do
      user = create(:user, first_name: "Thorin", last_name: "Oakenshield")

      expect(user.full_name).to eq "Thorin Oakenshield"
    end
  end

  describe ".search" do
    it "finds users whose first or last name matches the given regex" do
      jim = create(:user, first_name: "Jim", last_name: "Timothy", email: "kim@example.com")
      jane = create(:user, first_name: "Jane", last_name: "Not Jim", email: "jane@example.com")
      pat = create(:user, first_name: "Pat", last_name: "(not shown)", email: "pat@example.com")
      jin = create(:user, first_name: "Pat", last_name: "(not shown)", email: "jim@example.com")

      results = User.search("Jim")

      expect(results).to eq [jim, jane, jin]
    end

    it "finds users whose name matches all given terms" do
      jim = create(:user, first_name: "Jim", last_name: "Timothy")
      jane = create(:user, first_name: "Jane", last_name: "Not Jim")
      pat = create(:user, first_name: "Pat", last_name: "(not shown)")

      results = User.search("Jim Jane")

      expect(results).to eq [jane]
    end
  end

  describe "#able_to_edit?" do
    it "is true if the user has permission to edit and is active" do
      membership = create(:project_team_membership, can_edit_project: true, active: true)

      expect(membership.user).to be_able_to_edit(membership.project)
    end

    it "is false if the user does not have permission but is active" do
      membership = create(:project_team_membership, can_edit_project: false, active: true)

      expect(membership.user).to_not be_able_to_edit(membership.project)
    end

    it "is false if the user has permission but is not active" do
      membership = create(:project_team_membership, can_edit_project: true, active: false)

      expect(membership.user).to_not be_able_to_edit(membership.project)
    end
  end

  describe "#manager_of_reserve?" do
    it "is true if the user is a manager of the given reserve" do
      reserve = create(:reserve)
      user = create(:user)
      create(:reserve_personnel, reserve: reserve, user: user)

      expect(user.manager_of_reserve?(reserve)).to eq true
    end

    it "is false if the user is not a manager of the given reserve" do
      reserve = create(:reserve)
      user = create(:user)
      create(:reserve_personnel, user: user)

      expect(user.manager_of_reserve?(reserve)).to eq false
    end
  end

  describe "#is_manager?" do
    it "is true if user is a manager of any reserve" do
      reserve = create(:reserve)
      user = create(:user)
      create(:reserve_personnel, reserve: reserve, user: user)

      expect(user.is_manager?).to eq true
    end

    it "is false if user is not a manager of any reserve" do
      reserve = create(:reserve)
      user = create(:user)

      expect(user.is_manager?).to eq false
    end
  end

  describe ".non_group_users" do
    it "only returns user records of users that are not group" do
      create(:user, :non_group_user) if User.where(id: 1).blank?
      user1 = create(:user)
      user2 = create(:user)

      results = User.non_group_users

      expect(results).to match_array [user1, user2]
    end
  end

  describe ".with_role" do
    let(:user1) { create(:user, role: "faculty") }
    let(:user2) { create(:user, role: "research_scientist") }
    let(:user3) { create(:user, role: "other") }
    let(:user4) { create(:user, role: "faculty") }

    context "when given role is present" do
      it "returns only users with the given role" do
        results = User.with_role("faculty")

        expect(results).to match_array [user1, user4]
      end
    end

    context "when given role is NOT present" do
      it "returns all users" do
        results = User.with_role(nil)

        expect(results).to match_array [user1, user2, user3, user4]
      end
    end
  end

  describe ".search_institution" do
    let(:user1) { create(:user, institution:
      create(:institution, name: "the institution1", acronym: "acronym1", city: "city1")
    ) }
    let(:user2) { create(:user, institution:
      create(:institution, name: "institution2", acronym: "the a", city: "city2")
    ) }
    let(:user3) { create(:user, institution:
      create(:institution, name: "institution3", acronym: "acronym3", city: "the city3")
    ) }
    let(:user4) { create(:user, institution:
      create(:institution, name: "University of Coruscant", acronym: "UC", city: "Imperial City")
    ) }

    context "when given query is present" do
      describe ".search_institution" do
        it "returns all institutions where the name, city, acronym is similar
        to the passed value" do
          results = User.search_institution("the")

          expect(results).to match_array [user1, user2, user3]
        end

        it "returns an empty array if there are no institutions where the name is similar
        to the passed value" do
          results = User.search_institution("xyz")

          expect(results).to be_empty
        end
      end
    end

    context "when given query is NOT present" do
      it "returns all users" do
        results = User.search_institution(nil)

        expect(results).to match_array [user1, user2, user3, user4]
      end
    end
  end

  describe ".with_institution_type" do
    let(:user1) { create(
      :user, institution: create(:institution, institution_type: "university_of_california")
    ) }
    let(:user2) { create(
      :user, institution: create(:institution, institution_type: "k_12_education")
    ) }
    let(:user3) { create(
      :user, institution: create(:institution, institution_type: "business_entity")
    ) }
    let(:user4) { create(
      :user, institution: create(:institution, institution_type: "university_of_california")
    ) }

    context "when given institution_type is present" do
      it "returns only users with the given institution_type" do
        results = User.with_institution_type("university_of_california")

        expect(results).to match_array [user1, user4]
      end
    end

    context "when given institution_type is NOT present" do
      it "returns all users" do
        results = User.with_institution_type(nil)

        expect(results).to match_array [user1, user2, user3, user4]
      end
    end
  end

  describe ".sort_using" do
    context "when given sort_option is 'user_id'" do
      it "returns users sorted by higher user id first" do
        user1 = create(:user)
        user2 = create(:user)
        user3 = create(:user)
        user4 = create(:user)

        results = User.sort_using("user_id")

        expect(results).to eq [user4, user3, user2, user1]
      end
    end

    context "when given sort_option is 'last_name'" do
      it "returns users sorted by higher user id first" do
        user1 = create(:user, last_name: "d")
        user2 = create(:user, last_name: "a")
        user3 = create(:user, last_name: "z")
        user4 = create(:user, last_name: "y")

        results = User.sort_using("last_name")

        expect(results).to eq [user2, user1, user4, user3]
      end
    end

    context "when given sort_option is 'created_at'" do
      it "returns users sorted by higher user id first" do
        user1 = create(:user, created_at: 2.year.ago)
        user2 = create(:user, created_at: 3.year.ago)
        user3 = create(:user, created_at: 1.year.ago)
        user4 = create(:user, created_at: 4.year.ago)

        results = User.sort_using("created_at")

        expect(results).to eq [user3, user1, user2, user4]
      end
    end

    context "when given sort_option is NOT present" do
      it "returns all users unsorted" do
        user1 = create(:user)
        user2 = create(:user)
        user3 = create(:user)
        user4 = create(:user)

        results = User.sort_using(nil)

        expect(results).to eq [user1, user2, user3, user4]
      end
    end
  end
end
