# frozen_string_literal: true

class Manager::Visits::QuestionsIndexPresenter < Visits::QuestionsIndexPresenter
  def initialize(visit:, form: nil, form_url: nil, save_partial: nil)
    super(current_step: 3, visit: visit, form: form)
    @save_partial = save_partial
    @form_url = form_url || manager_reserve_visit_reserve_info_index_path(visit.reserve_id, visit.id)
  end

  attr_reader :save_partial, :form_url

  def save_btn_partial_path
    save_partial || "manager/visits/reserve_info/save_btn"
  end
end
