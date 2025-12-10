# frozen_string_literal: true

class NewFeatureForm
  include ActiveModel::Model

  def model_name
    ActiveModel::Name.new(NewFeature)
  end

  def initialize(new_feature: nil, params: {})
    @new_feature = new_feature || NewFeature.new
    assign(params)
  end

  attr_reader :new_feature

  delegate :valid?, :validate, :errors, to: :new_feature
  delegate_missing_to :new_feature

  def save
    begin
      new_feature.save!
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
