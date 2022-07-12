class ReserveForm
  include ActiveModel::Model

  def model_name
    ActiveModel::Name.new(Reserve)
  end

  def initialize(params: {})
    @reserve = Reserve.find_by(id: params[:id]) || Reserve.new
    assign(params)
  end

  attr_reader :reserve
  delegate :valid?, :validate, :errors, to: :reserve
  delegate_missing_to :reserve

  def save
    begin
      reserve.save!
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
