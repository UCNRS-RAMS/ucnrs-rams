class UsersController < ApplicationController
  layout false

  def index
    @presenter = UsersIndexPresenter.new(query: query)
  end

  def new
    form = UserForm.new
    @presenter = UserNewPresenter.new(
      form: form
    )
  end

  private

  def query
    params[:q]
  end
end
