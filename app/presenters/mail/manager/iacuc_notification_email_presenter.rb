class Mail::Manager::IacucNotificationEmailPresenter < Mail::VisitNewPresenter
  def initialize(visit)
    super(visit)
  end

  delegate :name,
    :short_name,
    :address_line_1,
    :address_line_2,
    :address_line_3,
    :managing_campus,
    :country,
    :phone_number,
    :email_address,
    :personnel,
    to: :visit_reserve,
    prefix: true

  attr_reader :visit

  delegate_missing_to :visit

  def visit_reserve_managing_campus_name
    visit_reserve_managing_campus.name
  end

  def project_questions_presenter
    Mail::ProjectQuestionsPresenter.new(project: visit.project)
  end
end
