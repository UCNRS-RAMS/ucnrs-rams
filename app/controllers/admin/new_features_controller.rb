class Admin::NewFeaturesController < Manager::ApplicationController
  before_action :authenticate_user!
  before_action :confirm_admin!

  layout "admin"

  def index
    @presenter = Admin::NewFeaturesIndexPresenter.new
  end

  def show
    new_feature = NewFeature.find(params[:id])
  end

  def new
    form = NewFeatureForm.new
    @presenter = Admin::NewFeatureNewPresenter.new(form: form)
  end

  def create
    form = NewFeatureForm.new(params: new_feature_params)

    if form.save
      redirect_to admin_new_features_path
    else
      @presenter = Admin::NewFeatureNewPresenter.new(form: form)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    new_feature = NewFeature.find(params[:id])
    form = NewFeatureForm.new(new_feature: new_feature)
    @presenter = Admin::NewFeatureNewPresenter.new(form: form)
  end

  def update
    new_feature = NewFeature.find(params[:id])
    form = NewFeatureForm.new(new_feature: new_feature, params: new_feature_params)

    if form.save
      redirect_to admin_new_features_path
    else
      @presenter = Admin::NewFeatureNewPresenter.new(form: form)
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def new_feature
    @new_feature ||= NewFeature.find(params[:id])
  end

  def new_feature_params
    params.require(:new_feature).permit(
      :title,
      :feature,
    )
  end
end
