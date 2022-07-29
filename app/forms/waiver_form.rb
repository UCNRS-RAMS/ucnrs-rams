class WaiverForm
  include ActiveModel::Model

  def model_name
    ActiveModel::Name.new(Waiver)
  end

  def initialize(waiver: nil, params: {})
    @waiver = waiver || Waiver.new
    assign(params)
  end

  attr_reader :waiver
  delegate :valid?, :validate, :errors, to: :waiver
  delegate_missing_to :waiver

  def save
    begin
      waiver.save!
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
