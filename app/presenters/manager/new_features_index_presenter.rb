class Manager::NewFeaturesIndexPresenter
  def initialize
  end

  def new_features
    NewFeature.all
  end
end
