class Manager::UserShowPresenter
  def initialize(user)
    @user = user
  end

  delegate_missing_to :user

  delegate :name, to: :institution, prefix: true
  delegate :institution_type, to: :institution

  def user
    UserPresenter.new(@user)
  end

  def institution
    InstitutionPresenter.new(@user.institution)
  end

  def number_of_project_members
    ProjectTeamMembership.select(:project_id).where(user_id: @user).group(:project_id).length
  end

  def number_of_visits
    UserVisit.select(:visit_id).where(user_id: @user).group(:visit_id).length
  end
end
