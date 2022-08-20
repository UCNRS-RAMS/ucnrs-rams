class ReservePermitForm
  include ActiveModel::Model

  def model_name
    ActiveModel::Name.new(ReservePermit)
  end

  def initialize(reserve_permit: nil, params: {})
    @reserve_permit = reserve_permit || ReservePermit.new
    assign(params)
  end

  attr_reader :reserve_permit
  delegate :valid?, :validate, :errors, to: :reserve_permit
  delegate_missing_to :reserve_permit

  def save
    begin
      reserve_permit.save!
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
