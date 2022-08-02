class Manager::ReserveInfo::ReserveQuestionsController < ApplicationController
  layout "manager"
  before_action :authenticate_user!
  before_action :confirm_manager!

  def index
    @presenter = Manager::ReserveInfo::ReserveQuestionsIndexPresenter.new(
      reserve: current_reserve,
    )
  end

  def edit
    form = ReserveQuestionForm.new(reserve_question: reserve_question)
    @presenter = Manager::ReserveInfo::ReserveQuestionEditPresenter.new(form: form)
  end

  def update
    form = ReserveQuestionForm.new(reserve_question: reserve_question, params: reserve_question_params)
    
    if form.save
      redirect_to manager_reserve_reserve_info_reserve_questions_path(current_reserve)
    else
      @presenter = Manager::ReserveInfo::ReserveQuestionEditPresenter.new(form: form)
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def reserve_question
    @reserve_question ||= current_reserve.reserve_questions.find(params[:id])
  end

  def reserve_question_params
    params.require(:reserve_question).permit(
      :id,
      :reserve_id,
      :question_type,
      :location,
      :question,
      :statement,
      :sort_order,
      :answer_required,
      :public_use,
      :university_class,
      :research,
      :housing,
      :conference,
      :visible,
      :authority,
      :description,
      :url_1,
      :url_link_text_1,
      :url_2,
      :url_link_text_2,
      :url_3,
      :url_link_text_3,
      :iacuc_flag,
      :drone_flag,
      :scuba_flag,
      :vertebrate_flag,
      :threatened_endangered_flag,
      :involves_mammals,
      :involves_reptiles,
      :involves_amphibians,
      :involves_fish,
      :involves_birds,
      :involves_plants_fungus_soil,
      :involves_none,
      :involves_all,
      :state_id,
    )
  end
end
