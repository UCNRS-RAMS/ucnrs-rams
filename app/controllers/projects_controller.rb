class ProjectsController < ApplicationController
  before_action :authenticate_user!

  def index
    @page = ProjectsIndexPresenter.new(
      user: current_user,
      status_filter: status_filter,
      page: page_number,
    )
  end

  def new
    @presenter = ProjectsNewPresenter.new(
      user: current_user,
      current_step: 1,
      project_type: project_type,
    )
  end

  def create
    form = ProjectForm.new(user: current_user, params: project_params)
    if form.save
      redirect_to root_path
    else
      @presenter = ProjectsNewPresenter.new(
        user: current_user,
        current_step: 1,
        project_type: form.project_type,
        form: form,
      )
      render :new, status: :unprocessable_entity
    end
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
    )
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
end
