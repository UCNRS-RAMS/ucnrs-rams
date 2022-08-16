# frozen_string_literal: true

class ReservePersonnelForm
  include ActiveModel::Model

  def model_name
    ActiveModel::Name.new(ReservePersonnel)
  end

  def initialize(reserve_personnel: nil, params: {})
    @reserve_personnel = reserve_personnel || ReservePersonnel.new
    assign(params)
  end

  attr_reader :reserve_personnel
  delegate :valid?, :validate, :errors, to: :reserve_personnel
  delegate_missing_to :reserve_personnel

  def save
    begin
      reserve_personnel.save!
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
