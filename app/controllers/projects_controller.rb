class ProjectsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_user, only: [:edit, :update]

  def index
    @presenter = ProjectsIndexPresenter.new(
      user: current_user,
      status_filter: status_filter,
      page: page_number,
    )
  end

  def new
    @presenter = ProjectFormPresenter.new(
      user: user,
      current_step: 1,
      project_type: project_type,
    )
  end

  def create
    form = ProjectForm.new(user: user, params: project_params)
    if form.save
      redirect_to project_team_memberships_path(form.project, format: :html)
    else
      @presenter = ProjectFormPresenter.new(
        user: user,
        current_step: 1,
        project_type: form.project_type,
        form: form,
        show_modal: false,
      )
      render :new, status: :unprocessable_entity
    end
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

  def show
    @presenter = ProjectShowPresenter.new(project)
  end

  private

  def project_params
    params.require(:project).permit(
      :title,
      :thesis_title,
      :abstract,
      :project_type,
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

  def user
    return current_user if params[:user_id].nil?

    User.find(params[:user_id])
  end

  def status_filter
    params[:status]
  end
 
  def page_number
    params[:page]
  end

  def project_type
    params[:project_type]
  end

  def authorize_user
    if !current_user.able_to_edit?(project)
      flash[:alert] = t("projects.not_authorized")
      redirect_to project_path(project)
    end
  end

  def project
    Project.find(project_id)
  end

  def project_id
    params.permit(:id).require(:id)
  end
end
