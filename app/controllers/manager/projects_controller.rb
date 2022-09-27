class Manager::ProjectsController < ApplicationController
  before_action :authenticate_user!
  before_action :confirm_reserve_manager!
  layout "manager"

  def index
    @presenter = Manager::ProjectsIndexPresenter.new(
      reserve: current_reserve,
      page: page_number,
      filter: filter,
    )
  end

  def show
    @presenter = Manager::ProjectShowPresenter.new(project: project, reserve: current_reserve)
  end

  def edit
    form = ProjectForm.new(user: current_user, params: { id: project.id })
    @presenter = ProjectFormPresenter.new(
      user: current_user,
      current_step: 1,
      project_type: project.project_type,
      form: form,
    )
  end

  def update
    form = ProjectForm.new(user: current_user, params: project_params.merge(id: project.id))
    if form.save
      redirect_to project_team_memberships_path(form.project, format: :html)
    else
      @presenter = ProjectFormPresenter.new(
        user: current_user,
        current_step: 1,
        project_type: form.project_type,
        form: form,
      )
      render :edit, status: :unprocessable_entity
    end
  end

  private
 
  def page_number
    params[:page]
  end

  def project_params
    params.require(:project).permit(
      :reserve_id,
      :title,
      :thesis_title,
      :abstract,
      :start_date,
      :end_date,
      :discipline,
      :discipline_other,
      :involves_mammals,
      :involves_reptiles,
      :involves_amphibians,
      :involves_fish,
      :involves_birds,
      :involves_plants_fungi_soil,
      :involves_threatened_endangered_species,
      :involves_none,
      :method_description,
      :method_study_area,
      :method_remove_organisms,
      :method_transfer_organisms,
      :method_study_non_native_species,
      :method_chemicals,
      :method_chemicals_list,
      :method_soil_disturbance,
      :method_long_term_structures,
      :course_title,
      :course_number,
      :keywords,
      :taxonomic_keywords,
      :recent_publications,
    )
  end

  def project
    @project ||= Project.find_by(id: project_id)
    return @project if @project

    flash[:alert] = I18n.t(".manager.projects.cannot_find_project")
    redirect_to root_path and return false
  end

  def project_id
    params.permit(:id).require(:id)
  end

  def reserve_id
    params.permit(:reserve_id).require(:reserve_id)
  end

  def filter
    if params[:filter].present?
      params.require(:filter).permit(
        :project_search,
        :project_status,
        :sort_by,
        :project_type,
        :date_range_type,
        :date_begin,
        :date_end,
        :reserve,
      )
    end
  end
end
