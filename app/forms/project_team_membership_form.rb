# frozen_string_literal: true

class ProjectTeamMembershipForm
  include ActiveModel::Model

  def model_name
    ActiveModel::Name.new(ProjectTeamMembership)
  end

  def initialize(project: nil, params: {})
    @project_team_membership = ProjectTeamMembership.where(id: params[:id]).first ||
      ProjectTeamMembership.new
    @project_team_membership.project ||= project
    activate_if_unset
    assign(params)
    maybe_set_institution_from_user
    maybe_set_user_role_from_user
  end

  attr_accessor :full_name
  attr_accessor :institution_name
  attr_reader :project_role

  attr_reader :project_team_membership
  delegate_missing_to :project_team_membership

  validates :project_role, inclusion: {
    in: ProjectTeamMembership::PROJECT_ROLES,
  }, if: :new_record?
  validates :institution_id, presence: true

  def project_role=(project_role)
    @project_role = project_role
    case project_role
    when ProjectTeamMembership::PRINCIPAL_INVESTIGATOR_ROLE
      self.is_principal_investigator = true
      self.can_edit_project = true
      self.can_add_project_user = true
      self.can_add_visit = true
      self.can_receive_invoice = true
    when ProjectTeamMembership::PROJECT_MANAGER_ROLE
      self.is_principal_investigator = false
      self.can_edit_project = true
      self.can_add_project_user = true
      self.can_add_visit = true
      self.can_receive_invoice = false
    when ProjectTeamMembership::TEAM_MEMBER_ROLE
      self.is_principal_investigator = false
      self.can_edit_project = false
      self.can_add_project_user = true
      self.can_add_visit = true
      self.can_receive_invoice = false
    when ProjectTeamMembership::BILLING_ROLE
      self.is_principal_investigator = false
      self.can_edit_project = false
      self.can_add_project_user = false
      self.can_add_visit = true
      self.can_receive_invoice = true
    else
      self.is_principal_investigator = false
      self.can_edit_project = false
      self.can_add_project_user = false
      self.can_add_visit = false
      self.can_receive_invoice = false
    end
  end

  def assigned_as_project_owner=(value)
    project.owner = user if value == "true"
  end

  def assigned_as_project_owner?
    project.user_id == user_id
  end

  alias_method :validate_form, :validate
  alias_method :valid_form?, :valid?
  def validate
    validate_form
    validate_project_team_membership
    copy_errors_to_self
    errors.empty?
  end
  alias_method :valid?, :validate

  def save
    ActiveRecord::Base.transaction do
      project.save(validate: false) if project.user_id_changed?
      validate && project_team_membership.save
    end
  end

  private

  def activate_if_unset
    if project_team_membership.active.nil?
      project_team_membership.active = true
    end
  end

  def validate_project_team_membership
    project_team_membership.validate
  end

  def copy_errors_to_self
    errors.merge!(project_team_membership.errors)
    errors[:user].each { |error| errors.add(:full_name, error) }
    errors[:institution_id].each { |error| errors.add(:institution_name, error) }
  end

  def maybe_set_institution_from_user
    if new_record?
      self.institution_id = Institution
        .joins(:users)
        .where(users: { id: user_id })
        .pick(:id)
    end
  end

  def maybe_set_user_role_from_user
    self.user_role ||= User
      .where(id: user_id)
      .pick(:role)
  end

  def assign(params)
    params.each do |key, value|
      public_send(:"#{key}=", value)
    end
  end

  def new_record?
    project_team_membership.new_record?
  end
end
