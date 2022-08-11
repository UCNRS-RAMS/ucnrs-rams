# frozen_string_literal: true

class AmenityRateCategoryForm
  include ActiveModel::Model

  def model_name
    ActiveModel::Name.new(AmenityRateCategory)
  end

  def initialize(amenity_rate_category: nil, params: {})
    @amenity_rate_category = amenity_rate_category || AmenityRateCategory.new
    assign(params)
  end

  attr_reader :amenity_rate_category
  delegate :valid?, :validate, :errors, to: :amenity_rate_category
  delegate_missing_to :amenity_rate_category

  def save
    begin
      amenity_rate_category.save!
      true
    rescue ActiveRecord::RecordInvalid => e
      Rails.logger.error(e)
      false
    end
  end

  private

  def assign(params)
    params.each do |key, value|
      self.send("#{key}=", value)
    end
  end
end
