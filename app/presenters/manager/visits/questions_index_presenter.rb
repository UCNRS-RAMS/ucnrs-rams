# frozen_string_literal: true

class Manager::Visits::QuestionsIndexPresenter < Visits::QuestionsIndexPresenter
  def initialize(visit:, form: nil)
    super(current_step: 3, visit: visit, form: form)
  end

  def form_url
    manager_reserve_visit_reserve_info_index_path(visit.reserve_id, visit.id)
  end

  def save_btn_partial_path
    "manager/visits/reserve_info/save_btn"
  end
end
