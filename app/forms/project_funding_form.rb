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
    @funding.project ||= project
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

  def funding_status=(value)
    case value.to_sym
    when :is_funded
      reset_funding_status
      funding.is_funded = true
    when :is_submitted
      reset_funding_status
      funding.is_submitted = true
    when :will_be_submitted
      reset_funding_status
      funding.will_be_submitted = true
    when :was_denied
      reset_funding_status
      funding.was_denied = true
    when :""
      reset_funding_status
    end
  end

  def funding_status
    if funding.is_funded?
      :is_funded
    elsif funding.is_submitted?
      :is_submitted
    elsif funding.will_be_submitted?
      :will_be_submitted
    elsif funding.was_denied?
      :was_denied
    end
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

  def reset_funding_status
    funding.is_funded = false
    funding.is_submitted = false
    funding.will_be_submitted = false
    funding.was_denied = false
  end
end
