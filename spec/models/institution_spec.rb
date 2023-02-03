require "rails_helper"

RSpec.describe Institution, type: :model do
  subject { create(:institution, name: "University of California", city: "San Francsico") }

  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:city) }
    it { is_expected.to validate_presence_of(:country) }
    it { is_expected.to validate_uniqueness_of(:name).scoped_to(:city).case_insensitive }
    it { is_expected.to validate_presence_of(:institution_type) }
  end

  describe "associations" do
    it { is_expected.to belong_to(:country) }
    it { is_expected.to belong_to(:state).optional(true) }
    it { is_expected.to have_many(:users).inverse_of(:institution).dependent(:restrict_with_error) }
    it { is_expected.to have_many(:project_team_memberships).inverse_of(:institution).dependent(:restrict_with_error) }
    it { is_expected.to have_many(:user_visits).inverse_of(:institution).dependent(:restrict_with_error) }
  end

  it do
    is_expected.to define_enum_for(:institution_type)
      .with_values(
        university_of_california: "University of California",
        california_state_university_system: "California State University System",
        california_community_college: "California Community College",
        other_california_university_or_college: "California - Other University or College",
        non_california_us_university_or_college: "U.S. - University or College Outside of California",
        international_university_or_college: "International University or College",
        k_12_education: "K-12 Education",
        non_governmental_organization_or_entity: "Non-Governmental Organization or Non-Profit Entity",
        governmental_organization_or_entity: "Governmental Agency or Entity",
        business_entity: "Business Entity",
        individual_or_other_entity: "Individual or Other Entity",
      ).backed_by_column_of_type(:string)
  end

  describe ".with_name_like" do
    it "returns all institutions where the name is similar to the passed value" do
      first_institution = create(:institution, name: "The Gnar Company")
      second_institution = create(:institution, name: "Gnarly Ways")
      third_institution = create(:institution, name: "The Bar Company")

      results = Institution.with_name_like("Gnar")

      expect(results).to match_array [first_institution, second_institution]
    end

    it "is case insensitive" do
      first_institution = create(:institution, name: "The GNAR Company")
      second_institution = create(:institution, name: "gnaRly Ways")
      third_institution = create(:institution, name: "The Bar Company")

      results = Institution.with_name_like("gnar")

      expect(results).to match_array [first_institution, second_institution]
    end

    it "returns an empty array if there are no institutions where the name is similar to the passed value" do
      create(:institution, name: "The Bar Company")

      results = Institution.with_name_like("Gnar")

      expect(results).to be_empty
    end
  end

  describe ".with_institution_type" do
    let(:institution1) { create(:institution, institution_type: "university_of_california") }
    let(:institution2) { create(:institution, institution_type: "k_12_education") }
    let(:institution3) { create(:institution, institution_type: "business_entity") }
    let(:institution4) { create(:institution, institution_type: "university_of_california") }

    context "when given institution_type is present" do
      it "returns only institutions with the given institution type" do
        results = Institution.with_institution_type("university_of_california")

        expect(results).to match_array [institution1, institution4]
      end
    end

    context "when given institution_type is NOT present" do
      it "returns all institutions" do
        results = Institution.with_institution_type(nil)

        expect(results).to match_array [institution1, institution2, institution3, institution4]
      end
    end
  end

  describe ".sorted_using" do
    let(:institution1) { create(:institution, name: "institution a", created_at: 3.month.ago) }
    let(:institution2) { create(:institution, name: "institution t", created_at: 1.month.ago) }
    let(:institution3) { create(:institution, name: "institution o", created_at: 2.month.ago) }
    let(:institution4) { create(:institution, name: "institution z", created_at: 4.month.ago) }

    context "when given sort_option name" do
      it "return records sorted alphabetically" do
        results = Institution.sorted_using(:name)

        expect(results).to eq [institution1, institution3, institution2, institution4]
      end
    end
    context "when given sort_option created_at" do
      it "return records sorted by latest created_at date first" do
        results = Institution.sorted_using(:created_at)

        expect(results).to eq [institution2, institution3, institution1, institution4]
      end
    end
  end

  describe ".in_country" do
    it "return only returns institution records with given country" do
      country = create(:country)
      institution1 = create(:institution, country: country)
      institution2 = create(:institution, country: country)
      create(:institution, country: create(:country))
      create(:institution, country: create(:country))
      create(:institution, country: create(:country))

      results = Institution.in_country(country)

      expect(results).to match_array [institution1, institution2]
    end
  end

  describe ".in_state" do
    it "return only returns institution records with given state" do
      state = create(:state)
      institution1 = create(:institution, state: state)
      institution2 = create(:institution, state: state)
      create(:institution, state: create(:state))
      create(:institution, state: create(:state))
      create(:institution, state: create(:state))

      results = Institution.in_state(state)

      expect(results).to match_array [institution1, institution2]
    end
  end

  describe ".search" do
    let(:institution1) { create(:institution, name: "the institution1", acronym: "acronym1", city: "city1") }
    let(:institution2) { create(:institution, name: "institution2", acronym: "the a", city: "city2") }
    let(:institution3) { create(:institution, name: "institution3", acronym: "acronym3", city: "the city3") }
    let(:institution4) { create(:institution, name: "University of Coruscant", acronym: "UC", city: "Imperial City") }

    context "when given query is present" do
      describe ".search" do
        it "returns all institutions where the name, city, acronym is similar
        to the passed value" do
          results = Institution.search("the")

          expect(results).to match_array [institution1, institution2, institution3]
        end

        it "returns an empty array if there are no institutions where the name is similar
        to the passed value" do
          results = Institution.search("xyz")

          expect(results).to be_empty
        end
      end
    end

    context "when given query is NOT present" do
      it "returns all institutions" do
        results = Institution.search(nil)

        expect(results).to match_array [institution1, institution2, institution3, institution4]
      end
    end
  end
end
