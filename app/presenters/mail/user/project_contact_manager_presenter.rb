# frozen_string_literal: true

class Mail::User::ProjectContactManagerPresenter
  def initialize(project:, reserve:, user:)
    @project = Mail::User::ProjectPresenter.new(project)
    @reserve = reserve
    @user = user
  end

  attr_reader :project

  delegate :id, :name, to: :reserve, prefix: true
  delegate :id, to: :project, prefix: true
  delegate :full_name, :email, to: :user, prefix: true

  def email_to
    reserve.email_address
  end

  def email_subject
    "Project #{project.id} discussion for [#{reserve.name}]".squish
  end

  private

  attr_reader :reserve, :user
end
