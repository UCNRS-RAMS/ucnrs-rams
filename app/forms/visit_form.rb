# frozen_string_literal: true

class VisitForm
  include ActiveModel::Model

  DEFAULT_TIME = "12:00"

  def model_name
    ActiveModel::Name.new(Visit)
  end

  def initialize(user: User.new, params: {}, editing: false )
    @visit = Visit.where(id: params[:id]).first || Visit.new
    @visit.user = user if visit.new_record?
    @project_type = params.delete(:project_type) || visit.project_type
    @visit.sign_token = SecureRandom.urlsafe_base64(48)
    @amenities_params = params.delete(:amenities) || {}
    @editing = editing
    assign(params)
  end

  attr_reader :visit, :editing, :project_type

  delegate_missing_to :visit

  validates :start_date, presence: true
  validates :end_date, presence: true

  alias_method :validate_form, :validate
  alias_method :valid_form?, :valid?
  def validate
    validate_form
    validate_visit
    validate_amenities
    copy_errors_to_self
    errors.empty?
  end
  alias_method :valid?, :validate

  def save
    begin
      Visit.transaction do
        save_visit!
        save_amenities!
        validate_form
      end
    rescue ActiveRecord::RecordInvalid => e
      validate
      false
    end
  end

  def editing=(edit)
    @editing = edit
  end

  def cancel_visit
    visit.assign_attributes(status: :cancelled)
    visit.save
  end

  def amenity_form(amenity_id)
    amenity_forms[amenity_id]
  end

  def start_date
    display_date(visit.starts_at)
  end

  def start_time
    display_time(visit.starts_at)
  end

  def end_date
    display_date(visit.ends_at)
  end

  def end_time
    display_time(visit.ends_at)
  end

  def start_date=(date)
    visit.start_date = parse_date(date)
    assign_starts_at
  end

  def start_time=(time)
    visit.start_time = parse_time(time)
    assign_starts_at
  end

  def end_date=(date)
    visit.end_date = parse_date(date)
    assign_ends_at
  end

  def end_time=(time)
    visit.end_time = parse_time(time)
    assign_ends_at
  end

  def submitted_at=(submitted_at)
    visit.submitted_at = submitted_at if policy_agreement
  end

  def update_status
    visit.save && update_user_visits_status && update_amenity_visits_status
  end

  private

  def assign(params)
    params.each do |key, value|
      self.send("#{key}=", value)
    end
  end

  def validate_visit
    visit.validate
  end

  def validate_amenities
    amenity_forms.each do |key, amenity_visits|
      amenity_visits.each do |amenity_visit|
        amenity_visit.visit_id = visit.id
        amenity_visit.validate
      end
    end
  end

  def copy_errors_to_self
    errors.merge!(visit.errors)
  end

  def save_visit!
    visit.save!
  end

  def save_amenities!
    destroy_removed_amenity_visits
    amenity_forms.each do |key, amenity_visits|
      amenity_visits.each do |amenity_visit|
        amenity_visit.visit_id = visit.id
        amenity_visit.save!
      end
    end
  end

  def display_date(date)
    date ? I18n.l(date, format: :visit_form_output_date) : ""
  end

  def display_time(time)
    time ? I18n.l(time, format: :visit_form_output_time) : DEFAULT_TIME
  end

  def parse_date(date_string)
    begin
      Time.strptime(
        date_string,
        I18n.translate("date.formats.visit_form_input_date"),
      )
    rescue ArgumentError, TypeError
      nil
    end
  end

  def parse_time(time_string)
    begin
      time_string.in_time_zone
    rescue ArgumentError, TypeError
      nil
    end
  end

  def amenity_forms
    @amenity_forms ||= amenities_params.each_with_object({}) do |params, forms|
      forms[params[:amenity_id].to_s] = amenity_visit_forms(params)
    end
  end

  private :valid_form?, :validate_form

  def assign_starts_at
    visit.starts_at = change_date_for_datetime(visit.start_time, visit.start_date)
  end

  def assign_ends_at
    visit.ends_at = change_date_for_datetime(visit.end_time, visit.end_date)
  end

  def change_date_for_datetime(datetime, date)
    if date.blank?
      datetime&.change(year: today.year, month: today.month, day: today.day)
    else
      datetime&.change(year: date.year, month: date.month, day: date.day)
    end
  end

  def amenities_params
    return amenities.ids.map { |id| { amenity_id: id } } if editing

    @amenities_params&.values&.select do |amenity_params|
      amenity_params[:amenity_id].present?
    end
  end

  def amenity_visit_forms(amenity_params)
    amenity_visit_form_params(amenity_params).map do |params|
      Visits::AmenityForm.new(user: user, params: params)
    end
  end

  def amenity_visit_form_params(amenity_params)
    params = amenity_params[:amenity_visits]&.values&.map do |amenity_visit_params|
      amenity_visit_params(amenity_visit_params, amenity_params)
    end
    params.presence || amenity_visits.where(amenity_id: amenity_params[:amenity_id]).ids.map do |id|
      { amenity_visit_id: id }
    end
  end

  def amenity_visit_params(amenity_visit_params, amenity_params)
    amenity_visit_params.merge({
      amenity_visit_id: amenity_visit_params[:id],
      amenity_id: amenity_params[:amenity_id],
      amenity_rate_id: amenity_params[:amenity_rate_id],
    })
  end

  def destroy_removed_amenity_visits
    amenity_visits.where(id: removed_amenity_visit_ids).destroy_all
  end

  def removed_amenity_visit_ids
    amenity_visit_ids - amenity_forms.values.flatten.map(&:id)
  end

  def update_user_visits_status
    begin
      user_visits.update_all(status: UserVisit.statuses[status])
      true
    rescue ActiveRecord::ActiveRecordError => e
      Rails.logger.error(e)
      false
    end
  end

  def update_amenity_visits_status
    begin
      amenity_visits.update_all(status: AmenityVisit.statuses[status])
      true
    rescue ActiveRecord::ActiveRecordError => e
      Rails.logger.error(e)
      false
    end
  end

  def today
    Time.zone.today
  end
end
