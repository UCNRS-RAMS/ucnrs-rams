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

  def purpose_options
    [ "research", "class", "meeting", "public" ]
  end

  def project_options
    [OpenStruct.new(name: "Select a project", id: nil), *Project.alphabetized]
  end

  def reserve_options
    [OpenStruct.new(name: "Select a reserve", id: nil), *Reserve.alphabetized]
  end

  def public_use_categories
    [
      "general-use",
      "community-event",
      "fundraiser",
      "k-12-class",
      "private-class",
      "volunteer",
    ]
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
