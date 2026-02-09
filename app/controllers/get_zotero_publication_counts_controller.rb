class GetZoteroPublicationCountsController < ApplicationController
  before_action :authenticate_user!

  def show
    zotero_id = params[:zotero_id].to_i

    result = Service::GetZoteroPublicationCountPresenter
      .new(HttpGetter, reserve_id: zotero_id)
      .fetch_reserve

    if result
      render json: result, layout: false
    else
      render json: { error: "Not found" }, layout: false, status: :not_found
    end
  end
end
