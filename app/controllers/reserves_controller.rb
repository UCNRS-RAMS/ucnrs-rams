class ReservesController < ApplicationController
  layout "with_reserve_hero_nav", only: :show

  def index
    @presenter = ReservesIndexPresenter.new(search_filter: search_filter, selected_tags: selected_tag_names)
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

  def selected_tag_names
    return {} if params[:tag_names].blank?
    params[:tag_names].values.reduce([], :concat)
  end
end
