require "rails_helper"

RSpec.describe Institution, type: :model do
  subject { create(:institution, name: "University of California", city: "San Francsico") }

  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:city) }
    it { is_expected.to validate_presence_of(:state) }
    it { is_expected.to validate_presence_of(:country) }
    it { is_expected.to validate_uniqueness_of(:name).scoped_to(:city).case_insensitive }
    it { is_expected.to validate_presence_of(:institution_type) }
  end

  describe "associations" do
    it { is_expected.to belong_to(:country) }
    it { is_expected.to belong_to(:state) }
    it { is_expected.to have_many(:users).inverse_of(:institution).dependent(:restrict_with_error) }
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
end
