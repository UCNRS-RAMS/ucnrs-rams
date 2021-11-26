require "rails_helper"

class AtLeastOneDummy < Struct.new(:option_one, :option_two)
  include ActiveModel::Validations
  validates :option_one, :option_two, must_select_at_least_one: { report_to: :reporter }

  attr_reader :reporter
end

RSpec.describe MustSelectAtLeastOneValidator, type: :model do
  describe "#validate" do
    it "adds an error if at least one of the attributes is not present" do
      dummy = AtLeastOneDummy.new(nil, false)

      dummy.validate

      expect(dummy.errors[:reporter]).to eq ["must select at least one"]
    end

    it "does not add an error if at least one of the attributes is present " do
      dummy = AtLeastOneDummy.new(true, false)

      dummy.validate

      expect(dummy.errors[:reporter]).to eq []
    end
  end
end
