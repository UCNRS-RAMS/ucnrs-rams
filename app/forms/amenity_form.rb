# frozen_string_literal: true

class AmenityForm
  include ActiveModel::Model

  def model_name
    ActiveModel::Name.new(Amenity)
  end

  def initialize(amenity: nil, params: {})
    @amenity = amenity || Amenity.new
    assign(params)
  end

  attr_reader :amenity
  delegate :valid?, :validate, :errors, to: :amenity
  delegate_missing_to :amenity

  def save
    begin
      amenity.save!
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
