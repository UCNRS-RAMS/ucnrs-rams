# frozen_string_literal: true

class Mail::User::ProjectCompletePresenter < Mail::ProjectCompletePresenter
  def initialize(project)
    super(project)
  end

  def email_subject
    "New Project #{project_name} - #{timeframe} - #{applicant_name}".squish
  end

  def team_member_emails
    team_members.map(&:email).reject(&:blank?)
  end
end
