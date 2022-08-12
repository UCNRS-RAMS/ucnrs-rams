# frozen_string_literal: true

class UserVisitForm
  include ActiveModel::Model

  def model_name
    ActiveModel::Name.new(UserVisit)
  end

  def initialize(params: {})
    @visit = Visit.find_by(id: params[:visit_id])
    @user = User.find_by(id: params[:user_id])
    @user_visit = UserVisit.find_by(id: params[:id]) || UserVisit.new(new_user_visit_params)
    assign(params)
    assign_guest_values if adding_user_as_guest_visitor?
  end

  delegate :name, to: :institution, prefix: true, allow_nil: true
  delegate_missing_to :user_visit

  validates :visit_id, presence: true
  validates :user_id, presence: true
  validates :institution_id, presence: true

  attr_reader :user_visit, :visit, :user

  alias validate_form validate
  alias valid_form? valid?

  def arrives_at=(date)
    date = add_default_time(date&.to_date, user_visit.visit.start_time)
    user_visit.arrives_at = date
  end

  def departs_at=(date)
    date = add_default_time(date&.to_date, user_visit.visit.end_time)
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

  def adding_user_as_guest_visitor?
    user_visit.guest_name.present? && user.present? && user.id != 1
  end

  def assign_guest_values
    user_visit.institution_id = user.institution_id
    user_visit.role = user.role || "no_selection"
  end

  def new_user_visit_params
    {
      arrives_at: add_default_time(visit&.start_date, visit&.start_time),
      departs_at: add_default_time(visit&.end_date, visit&.end_time),
    }
  end

  def add_default_time(date, time)
    return nil if date.blank?

    time.change(day: date.day, month: date.month, year: date.year)
  end

  def validate_user_visit
    user_visit.validate
  end

  def default_institution(params)
    return if institution_id.present?

    user_visit.institution_id = User.find_by(id: params[:user_id])&.institution_id
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
