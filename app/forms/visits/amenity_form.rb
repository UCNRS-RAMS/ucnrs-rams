# frozen_string_literal: true

class Visits::AmenityForm
  include ActiveModel::Model
  DEFAULT_TIME = "12:00"

  def class_name
    ActiveModel::Name.new(Amenity)
  end

  def initialize(user: User.new, params: {})
    @amenity_visit = AmenityVisit.where(
      id: params[:amenity_visit_id]
    ).first || AmenityVisit.new
    @amenity_visit.user = user
    assign_dates(params)
    assign(params)
  end

  attr_reader :amenity_visit
  delegate_missing_to :amenity_visit

  validates :amenity_id, presence: true
  validates :arrives_on, presence: true
  validates :departs_on, presence: true

  def assign_dates(params)
    if params[:arrives_on].present?
      params[:arrives] = "#{params[:arrives_on]} #{params[:arrives_at]}"
      params[:departs] = "#{params[:departs_on]} #{params[:departs_at]}"
    end
  end

  def checked
    if amenity_id.present?
      "checked"
    end
  end

  def arrives_on
    display_date(amenity_visit.arrives_on)
  end

  def arrives_at
    display_time(amenity_visit.arrives_at)
  end

  def departs_on
    display_date(amenity_visit.departs_on)
  end

  def departs_at
    display_time(amenity_visit.departs_at)
  end

  def arrives_on=(date)
    amenity_visit.arrives_on = parse_date(date)
  end

  def arrives_at=(time)
    amenity_visit.arrives_at = parse_time(time)
  end

  def departs_on=(date)
    amenity_visit.departs_on = parse_date(date)
  end

  def departs_at=(time)
    amenity_visit.departs_at = parse_time(time)
  end

  alias_method :validate_form, :validate
  alias_method :valid_form?, :valid?

  def validate
    validate_form
    validate_amenity_visit
    copy_errors_to_self
    errors.empty?
  end
  alias_method :valid?, :validate

  def save
    if valid_form?
      AmenityVisit.transaction do
        save_amenity_visit!
      end
    end
  end

  private

  def validate_amenity_visit
    amenity_visit.validate
  end

  def save_amenity_visit!
    amenity_visit.save!
  end

  def copy_errors_to_self
    errors.merge!(amenity_visit.errors)
  end

  def assign(params)
    params.each do |key, value|
      self.send("#{key}=", value)
    end
  end

  def display_date(date)
    date ? I18n.l(date, format: :visit_form_output_date) : ""
  end

  def display_time(time)
    time ? I18n.l(time, format: :visit_form_output_time) : DEFAULT_TIME
  end

  def parse_date(date)
    begin
      Date.strptime(date, I18n.t("date.formats.visit_form_input_date"))
    rescue ArgumentError, TypeError
      nil
    end
  end

  def parse_time(time)
    begin
      Time.strptime("#{time} -0000", I18n.t("time.formats.visit_form_input_time"))
    rescue ArgumentError, TypeError
      nil
    end
  end

  private :valid_form?, :validate_form
end
