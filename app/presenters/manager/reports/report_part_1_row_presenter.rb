class Manager::Reports::ReportPart1RowPresenter
  def initialize(row)
    @row = row
  end

  attr_reader :row

  delegate_missing_to :row

  def role
    user_role_key.present? ? I18n.t("universal.role.#{user_role_key}") : @row['role']
  end

  def user_role_key
    User.roles.key(@row['role'])
  end
end
