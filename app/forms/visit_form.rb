class VisitForm
  include ActiveModel::Model

  def model_name
    ActiveModel::Name.new(Visit)
  end

  def initialize(user: User.new, params: {})
    @visit = Visit.where(id: params[:id]).first || Visit.new
    @visit.user = user
    @visit.sign_token = SecureRandom.urlsafe_base64(48)
    @amenities_params = params.delete(:amenities) || {}
    assign(params)
  end

  attr_reader :visit

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
        true
      end
    rescue ActiveRecord::RecordInvalid => e
      validate
      false
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

  def project_type=(category)
    visit.project_type = category
    if public_use?
      visit.project_id = Visit::PUBLIC_PROJECT_ID
    end
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
    amenity_forms.each do |key, amenity|
      amenity.visit_id = visit.id
      amenity.validate
    end
  end

  def copy_errors_to_self
    errors.merge!(visit.errors)
  end

  def save_visit!
    visit.save!
  end

  def save_amenities!
    amenity_forms.each do |key, amenity|
      amenity.visit_id = visit.id
      amenity.save!
    end
  end

  def display_date(date)
    date ? I18n.l(date, format: :visit_form_output_date) : ""
  end

  def display_time(time)
    time ? I18n.l(time, format: :visit_form_output_time) : ""
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
      Time.strptime(
        "#{time_string} -0000",
        I18n.translate("time.formats.visit_form_input_time")
      )
    rescue ArgumentError, TypeError
      nil
    end
  end

  def amenity_forms
    @amenity_forms ||= @amenities_params.values.each_with_object({}) do |params, forms|
      amenity_id = params[:amenity_id].to_s
      next if amenity_id.blank?
      forms[amenity_id] = AmenityForm.new(
        user: user,
        params: params,
      )
    end
  end

  private :valid_form?, :validate_form
end
