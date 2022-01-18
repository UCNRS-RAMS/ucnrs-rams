# frozen_string_literal: true

class ProjectFundingForm
  DECIMAL_NUMBER_PATTERN = /[^.\d]/

  include ActiveModel::Model

  def model_name
    ActiveModel::Name.new(Funding)
  end

  attr_reader :funding

  delegate :errors, :valid?, :validate, to: :funding
  delegate_missing_to :funding

  def initialize(project: nil, params: {})
    @funding = Funding.find_by(id: params[:id]) || Funding.new
    @funding.project = project
    assign(params)
  end

  def award_amount=(value)
    funding.award_amount = award_amount_as_integer(value)
  end

  def is_funded=(value)
    funding.is_funded = value == "1" 
  end

  def is_submitted=(value)
    funding.is_submitted = value == "1" 
  end

  def will_be_submitted=(value)
    funding.will_be_submitted = value == "1" 
  end

  def was_denied=(value)
    funding.was_denied = value == "1" 
  end

  def is_funded
    funding.is_funded == true ? "1" : "0"
  end

  def is_submitted
    funding.is_submitted == true ? "1" : "0"
  end

  def will_be_submitted
    funding.will_be_submitted == true ? "1" : "0"
  end

  def was_denied
    funding.was_denied == true ? "1" : "0"
  end

  private

  def assign(params)
    params.each do |key, value|
      self.send("#{key}=", value)
    end
  end

  def award_amount_as_integer(value)
    value.to_s.strip.gsub(DECIMAL_NUMBER_PATTERN, "").to_i
  end
end
