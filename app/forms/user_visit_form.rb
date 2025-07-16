# frozen_string_literal: true

class UserVisitForm
  include ActiveModel::Model

  def model_name
    ActiveModel::Name.new(UserVisit)
  end

  def initialize(params: {})
    @params = params
    @user = User.find_by(id: params[:user_id])
    @user_visit = UserVisit.find_by(id: params[:id]) || UserVisit.new(new_user_visit_params)
    assign(params.except(:institution))
    assign_guest_values if adding_guest_visitor?
    @institution_form = InstitutionForm.new(institution_form_params(params))
  end

  delegate :project_id, to: :visit, prefix: true
  delegate_missing_to :user_visit

  validates :visit_id, presence: true
  validates :user_id, presence: true
  validates :institution_id, presence: true

  attr_accessor :userdays
  attr_reader :user_visit, :visit, :user, :institution_form
  attr_writer :manual_user_days

  alias validate_form validate
  alias valid_form? valid?

  def arrives_at=(date)
    date = add_default_time(date&.to_date, arrives_time(date&.to_date))
    user_visit.arrives_at = date
  end

  def departs_at=(date)
    date = add_default_time(date&.to_date, departs_time(date&.to_date))
    user_visit.departs_at = date
  end

  def role=(role)
    user_visit.role = UserVisit.roles[role] || "other"
  end

  def manual_user_days
    if params[:manual_user_days].present?
      @manual_user_days
    elsif user_visit.actual_days > 0
      user_visit.actual_days * user_visit.count
    end
  end

  def validate
    validate_form
    validate_user_visit
    validate_institution
    copy_errors_to_self
    errors.empty?
  end

  alias valid? validate

  def save
    if validate
      ActiveRecord::Base.transaction do
        institution_form.submit
        user_visit.institution_id = institution_form.id
        user_visit.save
      end
    end
  end

  private

  attr_reader :params

  def arrives_time(date)
    return nil if date.blank?

    if date == visit&.starts_at&.to_date
      visit.starts_at
    else
      date.beginning_of_day
    end
  end

  def visit
    @visit ||= Visit.find_by(id: params[:visit_id]) || user_visit&.visit
  end

  def departs_time(date)
    return nil if date.blank?

    if date == visit&.ends_at&.to_date
      visit&.ends_at
    else
      date.end_of_day
    end
  end

  def institution_form_params(params)
    params.delete(:institution) || { id: user_visit.institution_id }
  end

  def adding_user_as_guest_visitor?
    user_visit.guest_name.present? && user.present? && user.id != 1
  end

  def adding_guest_visitor?
    user_visit.guest_name.present?
  end

  def assign_guest_values
    user_visit.count = 1
    if adding_user_as_guest_visitor?
      user_visit.institution_id = user.institution_id
      self.role = user.role
      user_visit.guest_name = nil
    end
  end

  def new_user_visit_params
    {
      arrives_at: visit&.starts_at == Visit.new.starts_at ? Time.zone.now.at_midday : visit&.starts_at,
      departs_at: visit&.ends_at == Visit.new.ends_at ? Time.zone.now.at_midday : visit&.ends_at,
    }
  end

  def add_default_time(date, time)
    return nil if date.blank?

    time.change(day: date.day, month: date.month, year: date.year)
  end

  def validate_user_visit
    user_visit.validate
  end

  def validate_institution
    institution_form.valid?
  end

  def copy_errors_to_self
    errors.merge!(user_visit.errors)
    errors.merge!(institution_form.errors)
  end

  def assign(params)
    params.each do |key, value|
      public_send("#{key}=", value)
    end

    assign_manual_actual_days
  end

  def assign_manual_actual_days
    case userdays
    when "manual"
      user_visit.actual_days = manual_user_days.to_f / user_visit.count
    when "auto_calculate"
      user_visit.actual_days = 0
    end
  end
end
