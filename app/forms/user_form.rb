class UserForm
  include ActiveModel::Model
  include InstitutionSelectable

  def model_name
    ActiveModel::Name.new(User)
  end

  def initialize(applicant: nil, project: nil, params: {})
    @applicant = applicant
    @project = project
    @user = User.new
    assign(params)
    # maybe_assign_placeholder_email
    assign_user_role
    assign_placeholder_data_for_non_registered_users

    @project_team_membership = initialize_project_team_membership
  end

  attr_reader :user, :project_role, :applicant, :project_team_membership, :project
  attr_accessor :is_principal_investigator,
    :can_edit_project,
    :can_add_project_user,
    :can_add_visit,
    :can_receive_invoice,
    :project_id,
    :institution_name,
    :institution_selection_type,
    :user_role

  delegate_missing_to :user

  validates :project_role, inclusion: {
    in: ProjectTeamMembership::PROJECT_ROLES,
  }

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

  def institution_id=(institution_id)
    @institution_selection_id = institution_id
    user.institution_id = institution_id
  end

  def institution_id
    return @institution_selection_id if defined?(@institution_selection_id)

    user.institution_id
  end

  def institution_id_before_type_cast
    institution_id
  end

  alias_method :validate_form, :validate
  alias_method :valid_form?, :valid?
  def validate
    validate_form
    validate_user
    validate_project_team_membership
    copy_errors_to_self
    errors.empty?
  end
  alias_method :valid?, :validate

  def save
    @institution_selection_error_messages = nil

    begin
      User.transaction do
        assign_selected_institution!
        save_user!
        save_project_team_membership!
        true
      end
    rescue ActiveRecord::RecordInvalid => e
      # Re-validating below clears user.errors, so any institution-selection
      # failure message added in assign_selected_institution! would otherwise
      # be lost; re-apply it afterwards.
      validate
      reapply_institution_selection_errors
      Rails.logger.error(e)
      false
    end
  end

  private

  def assign(params)
    params.each do |key, value|
      self.send("#{key}=", value)
    end
  end

  def assign_user_role
    user.role = self.user_role
  end

  def assign_selected_institution!
    return if institution_selection_type.blank?

    institution = resolve_institution_selection(
      id: @institution_selection_id,
      type: institution_selection_type,
      error_target: user.errors,
      error_attribute: :institution,
    )
    unless institution
      @institution_selection_error_messages = user.errors[:institution].dup
      raise ActiveRecord::RecordInvalid, user
    end

    user.institution = institution
    project_team_membership.institution = institution
  end

  def reapply_institution_selection_errors
    Array(@institution_selection_error_messages).each do |message|
      errors.add(:institution_name, message) unless errors.added?(:institution_name, message)
    end
  end

  def maybe_assign_placeholder_email
    if user.email.blank? && applicant.present?
      user.email = "user-#{SecureRandom.hex(10)}-#{applicant.id}@ucnature.org"
    end
  end

  def assign_placeholder_data_for_non_registered_users
    placeholder_data = User.placeholder_data_for_non_registered_users
    user.assign_attributes(placeholder_data)
  end

  def initialize_project_team_membership
    ProjectTeamMembership.new(
      institution_id: institution_id,
      user_role: user_role,
      active: true,
      project: project,
      is_principal_investigator: self.is_principal_investigator,
      can_edit_project: self.can_edit_project,
      can_add_project_user: self.can_add_project_user,
      can_add_visit: self.can_add_visit,
      can_receive_invoice: self.can_receive_invoice,
      user: user,
    )
  end

  def copy_errors_to_self
    errors.merge!(user.errors)
    errors[:institution].each { |error| errors.add(:institution_name, error) }
    errors[:role].each { |error| errors.add(:user_role, error) }
  end

  def validate_user
    user.validate
  end

  def save_user!
    user.save!
  end

  def validate_project_team_membership
    project_team_membership.validate
  end

  def save_project_team_membership!
    project_team_membership.save!
  end
end
