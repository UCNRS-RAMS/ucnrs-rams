# frozen_string_literal: true

class Projects::FundingEditPresenter
  include Rails.application.routes.url_helpers

  def initialize(form:)
    @form = form
  end

  attr_reader :form
  delegate :id, :errors, :project, to: :form

  def project_id
    editing_funding.project_id
  end

  def editing_funding
    Projects::FundingPresenter.new(
      Funding.find(id)
    )
  end

  def funding_title
    editing_funding.title
  end

  def sponsor_options
    Funding.sponsors.map { |key, value| [value, key] }
  end

  def sponsor
    if funding_sponsor == "other"
      sponsor_other
    else
      Funding.sponsors[funding_sponsor]
    end
  end

  def funding_form_path
    funding_path(id)
  end

  def funding_status_options
    {
      I18n.t("universal.funding.funding_status.is_funded") => :is_funded,
      I18n.t("universal.funding.funding_status.is_submitted") => :is_submitted,
      I18n.t("universal.funding.funding_status.will_be_submitted") => :will_be_submitted,
      I18n.t("universal.funding.funding_status.was_denied") => :was_denied,
    }
  end
end
