class VisitsNewPresenter
  def initialize(form: VisitForm.new)
    @form = form
  end

  attr_reader :form

  delegate :visit,
    :arrival_date,
    :arrival_time,
    :departure_date,
    :departure_time, to: :form

  def amenities
    Visits::AmenitiesPresenter.new(reserve_id: visit.reserve_id).amenities
  end

  def project_type_options
    Visit.project_type_options.keys.map do |option|
      option.tr(" ", "-")
    end
  end

  def project_options
    [OpenStruct.new(name: "Select a project", id: nil), *Project.alphabetized]
  end

  def reserve_options
    [OpenStruct.new(name: "Select a reserve", id: nil), *Reserve.alphabetized]
  end

  def public_use_categories
    Visit.public_use_categories.keys
  end

  def translate_in(context)
    lambda do |key|
      I18n.t("visits.form#{context}.#{key.tr("-", "_")}")
    end
  end

  def time_options
    midnight = Time.current.beginning_of_day
    (0..47).to_a.map do |i|
      OpenStruct.new(
        value: (midnight + (i * 30).minutes).strftime("%H%M"),
        human: (midnight + (i * 30).minutes).strftime("%I:%M %p"),
      )
    end
  end

  def default_public_use_category
    nil
  end
end
