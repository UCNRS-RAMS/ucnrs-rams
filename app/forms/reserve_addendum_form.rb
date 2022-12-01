class ReserveAddendumForm
  include ActiveModel::Model

  def model_name
    ActiveModel::Name.new(ReserveAddendum)
  end

  def initialize(reserve_addendum: nil, params: {})
    @reserve_addendum = reserve_addendum || ReserveAddendum.new
    assign(params)
  end

  attr_reader :reserve_addendum
  delegate :valid?, :validate, :errors, to: :reserve_addendum
  delegate_missing_to :reserve_addendum

  def save
    begin
      reserve_addendum.save!
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
