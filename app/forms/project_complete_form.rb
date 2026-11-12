class ProjectCompleteForm
  include ActiveModel::Model

  def model_name
    ActiveModel::Name.new(Project)
  end

  attr_reader :project

  def initialize(params: {})
    @project = Project.find_by(id: params[:id])
    @reserve_ids = Array(params[:reserve_ids]).compact_blank
  end

  def save
    @first_submission = project.incomplete?
    project.update_project_status

    saved = Project.transaction do
      replace_reserve_interests!
      project.save || raise(ActiveRecord::Rollback)
    end
    saved.present?
  end

  def first_submission?
    @first_submission
  end

  def selected_reserves
    @selected_reserves ||= Reserve.where(id: reserve_ids).to_a
  end

  private

  attr_reader :reserve_ids

  def replace_reserve_interests!
    project.reserve_interests.where.not(reserve_id: selected_reserves.map(&:id)).delete_all
    selected_reserves.each do |reserve|
      project.reserve_interests.find_or_create_by!(reserve: reserve)
    end
  end
end
