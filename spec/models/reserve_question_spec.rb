require "rails_helper"

RSpec.describe ReserveQuestion, type: :model do
  describe "assocations" do
    it { is_expected.to belong_to(:reserve) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:question_type) }
    it { is_expected.to validate_booleanish_values(:answer_required) }
    it { is_expected.to validate_booleanish_values(:public_use) }
    it { is_expected.to validate_booleanish_values(:university_class) }
    it { is_expected.to validate_booleanish_values(:research) }
    it { is_expected.to validate_booleanish_values(:housing) }
    it { is_expected.to validate_booleanish_values(:conference) }
  end

  describe "enums" do
    it do
      is_expected.to define_enum_for(:location)
        .with_values(
          visit: "visit",
          project: "project",
        ).backed_by_column_of_type(:string)
    end

    it do
      is_expected.to define_enum_for(:question_type)
        .with_values(
          boolean: "Boolean",
          text: "Text",
        ).backed_by_column_of_type(:string)
    end
  end

  describe "#reserve_name" do
    it "returns the reserve name of the reserve record associated with the reserve question." do
      reserve = create(:reserve, name: "Over Under Reserve")
      reserve_question = create(:reserve_question, reserve: reserve)

      expect(reserve_question.reserve_name).to eq "Over Under Reserve"
    end
  end
end
