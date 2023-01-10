class ReservesController < ApplicationController
  layout "with_reserve_hero_nav", only: :show

  def index
    @presenter = ReservesIndexPresenter.new(search_filter: search_filter, tag_types: selected_tag_types, tag_names: selected_tag_names)
  end

  def show
    reserve = Reserve.includes(personnel: [:user]).find(reserve_id)

    @presenter = ReserveShowPresenter.new(reserve: reserve)
  end

  private

  def search_filter
    params[:search_filter]
  end

  def reserve_id
    params.permit(:id).require(:id)
  end

  def selected_tag_types
    params[:tag_type][:selected] if params[:tag_type].present?
  end

  def selected_tag_names
    return {} if params[:tag_names].blank?
    params[:tag_names] 
  end
end
