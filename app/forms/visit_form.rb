class VisitForm
  include ActiveModel::Model

  def model_name
    ActiveModel::Name.new(Visit)
  end

  def initialize(user:, params: {})
    @visit = Visit.where(id: params[:id]).first || Visit.new
    @user = user
    @amenities_params = params.delete(:amenities) || {}
    assign(params)
  end

  attr_reader :visit

  delegate_missing_to :visit

  validates :start_date, presence: true
  validates :end_date, presence: true

  def save
    begin
      Visit.transaction do
        validate_everything
        if errors.blank?
          save_visit
          save_amenities
        end
      end
    rescue ActiveRecord::RecordInvalid => e
    end
  end

  def amenity_form(amenity_id)
    amenity_forms[amenity_id]
  end

  def start_date
    display_date(visit.start_date)
  end

  def start_time
    display_time(visit.start_time)
  end

  def end_date
    display_date(visit.end_date)
  end

  def end_time
    display_time(visit.end_time)
  end

  private

  def assign(params)
    params.each do |key, value|
      self.send("#{key}=", value)
    end
  end

  def validate_everything
    validate
    validate_visit
    validate_amenities
    copy_errors_to_self
  end

  def validate_visit
    visit.validate
  end

  def validate_amenities
    amenity_forms.each do |key, amenity|
      amenity.validate
    end
  end

  def copy_errors_to_self
    errors.merge!(visit.errors)
    amenity_forms.each do |key, amenity|
      errors.merge!(amenity.errors)
    end
  end

  def save_visit
    if public_use?
      visit.project_id = 0
    end
    visit.status = :temp
    visit.sign_token = SecureRandom.urlsafe_base64(48)
    visit.user = @user
    visit.save!
  end

  def save_amenities

  end

  def start_date=(date)
    visit.start_date = parse_date(date)
  end

  def start_time=(time)
    visit.start_time = parse_time(time)
  end

  def end_date=(date)
    visit.end_date = parse_date(date)
  end

  def end_time=(time)
    visit.end_time = parse_time(time)
  end

  def display_date(date)
    date ? I18n.l(date, format: :visit_form_output_date) : ""
  end

  def display_time(time)
    time ? I18n.l(time, format: :visit_form_output_time) : ""
  end

  def parse_date(date_string)
    if date_string.present?
      Time.strptime(date_string, I18n.translate("date.formats.visit_form_input_date"))
    else
      nil
    end
  end

  def parse_time(time_string)
    if time_string.present?
      Time.strptime(
        "#{time_string} -0000",
        I18n.translate("time.formats.visit_form_input_time")
      )
    else
      nil
    end
  end

  def amenity_forms
    @amenity_forms ||= @amenities_params.values.each_with_object({}) do |params, forms|
      forms[params[:amenity_id].to_s] = AmenityForm.new(params)
    end
  end
end
