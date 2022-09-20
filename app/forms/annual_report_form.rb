class AnnualReportForm
  include ActiveModel::Model

  def model_name
    ActiveModel::Name.new(AnnualReport)
  end

  def initialize(annual_report: nil, params: {})
    @annual_report = annual_report || AnnualReport.new
    assign(params)
  end

  attr_reader :annual_report
  delegate :valid?, :validate, :errors, to: :annual_report
  delegate_missing_to :annual_report

  def save
    begin
      annual_report.save!
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
