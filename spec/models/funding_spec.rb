require "rails_helper"

RSpec.describe Funding, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:project) }
    it { is_expected.to belong_to(:reserve).optional(true) }
  end

  describe "validations" do
    subject { Funding.new(start_date: Date.current, end_date: Date.current + 1.day) }

    it { is_expected.to validate_booleanish_values(:is_funded) }
    it { is_expected.to validate_booleanish_values(:is_submitted) }
    it { is_expected.to validate_booleanish_values(:will_be_submitted) }
    it { is_expected.to validate_booleanish_values(:was_denied) }
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:principal_investigators) }
    it { is_expected.to validate_presence_of(:start_date) }
    it { is_expected.to validate_presence_of(:end_date) }
    it { is_expected.to validate_date(:end_date).is_after(:start_date) }
    it { is_expected.to validate_presence_of(:sponsor) }
    it { is_expected.to validate_numericality_of(:award_amount).allow_nil }

    context "when sponsor is 'Other'" do
      subject { Funding.new(sponsor: "Other") }
      it { is_expected.to validate_presence_of(:sponsor_other) }
    end

    context "when sponsor is not 'Other'" do
      subject { Funding.new(sponsor: "U.S. Geological Survey (USGS)") }
      it { is_expected.not_to validate_presence_of(:sponsor_other) }
    end
  end

  it do 
    is_expected.to define_enum_for(:sponsor)
      .with_values(
        national_science_foundation: "National Science Foundation (NSF)",
        national_institute_of_health: "National Institute of Health (NIH)",
        us_geological_survey: "U.S. Geological Survey (USGS)",
        us_forest_service: "U.S. Forest Service (USFS)",
        us_dept_of_agriculture: "U.S. Department of Agriculture (USDA)",
        ca_dept_of_fish_and_wildlife: "California Department of Fish and Wildlife",
        other: "Other",
      ).backed_by_column_of_type(:string)
  end
end
