class Manager::Projects::DetailController < ApplicationController
  def edit
    @presenter = ProjectFormPresenter.new(
      user: current_user,
      current_step: 1,
      project_type: project.project_type,
      form: ProjectForm.new(user: current_user, params: { id: project.id }),
    )
  end

  def update
    form = ProjectForm.new(user: current_user, params: project_params.merge(id: project.id))
    if form.save
      redirect_to manager_reserve_project_path(project.reserve_id, project.id)
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

  def project
    Project.find(project_id)
  end

  def project_id
    params.permit(:project_id).require(:project_id)
  end

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
end
