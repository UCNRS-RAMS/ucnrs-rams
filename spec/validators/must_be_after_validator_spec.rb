require "rails_helper"

class MustBeAfterDummy < Struct.new(:date, :early_date)
  include ActiveModel::Validations
  validates :date, must_be_after: :early_date
end

RSpec.describe MustBeAfterValidator do
  before do
    I18n.backend.store_translations(:en, {
      activemodel: {
        attributes: {
          must_be_after_dummy: {
            early_date: "the earlier of the dates"
          }
        }
      }
    })
  end

  it "must be after the 'early date'" do
    dummy = MustBeAfterDummy.new(Time.current, 1.day.ago)
    expect(dummy).to be_valid
  end

  it "must be after the 'early date' or we get an error" do
    dummy = MustBeAfterDummy.new(Time.current, 1.day.from_now)
    expect(dummy).to_not be_valid
    expect(dummy.errors.full_messages).to eq [
      "Date must be after the earlier of the dates"
    ]
  end
end
