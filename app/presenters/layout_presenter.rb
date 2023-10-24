# frozen_string_literal: true

class LayoutPresenter
  MANAGER_NAMESPACE = "manager"

  def initialize(current_user: nil, current_reserve: nil, controller_path: "", dashboard: nil)
    @current_user = current_user
    @current_reserve = current_reserve
    @controller_path = controller_path
    @dashboard = dashboard
  end

  attr_reader :current_user, :current_reserve

  delegate :name, :managing_campus, to: :current_reserve, prefix: true
  delegate :full_name, to: :current_user, prefix: true

  def current_user_logged_in?
    current_user.present?
  end

  def current_user_is_manager_admin?
    current_user&.is_manager? || current_user_is_admin?
  end

  def current_user_is_admin?
    current_user&.admin?
  end

  def current_user_managed_reserves
    current_user.managed_reserves.alphabetized
  end

  def admin_reserves
    Reserve.alphabetized
  end

  def current_user_first_managed_reserve
    current_user.managed_reserve_ids.first
  end

  def in_manager_namespace?
    controller_path.split("/").first == MANAGER_NAMESPACE
  end

  def current_reserve_managing_campus_name
    current_reserve_managing_campus&.name
  end

  def current_user_dashboard
    dashboard&.to_sym
  end

  def current_reserve_logo
    current_reserve.logo_src(:medium)
  end

  private

  attr_reader :controller_path, :dashboard
end
