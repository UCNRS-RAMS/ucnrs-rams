# frozen_string_literal: true

class UserVisitForm
  include ActiveModel::Model

  def model_name
    ActiveModel::Name.new(UserVisit)
  end

  def initialize(params: {})
    @user_visit = UserVisit.find_by(id: params[:id]) || UserVisit.new
    assign(params)
  end

  delegate :name, to: :institution, prefix: true, allow_nil: true
  delegate_missing_to :user_visit

  validates :visit_id, presence: true, numericality: { only_integer: true }
  validates :user_id, presence: true, numericality: { only_integer: true }
  validates :institution_id, presence: true, numericality: { only_integer: true }

  attr_reader :user_visit

  alias validate_form validate
  alias valid_form? valid?

  def arrives_at=(date)
    date = add_default_time(date, user_visit.visit.start_time)
    user_visit.arrives_at = date
  end

  def departs_at=(date)
    date = add_default_time(date, user_visit.visit.end_time)
    user_visit.departs_at = date
  end

  def validate
    validate_form
    validate_user_visit
    copy_errors_to_self
    errors.empty?
  end

  alias valid? validate

  def save
    validate && user_visit.save
  end

  private

  def add_default_time(date, time)
    return nil if date.blank?

    "#{date} #{I18n.l(time, format: :form_input_time)}"
  end

  def validate_user_visit
    user_visit.validate
  end

  def copy_errors_to_self
    errors.merge!(user_visit.errors)
  end

  def assign(params)
    params.each do |key, value|
      public_send("#{key}=", value)
    end
  end
end
