class Manager::ReserveInfo::ReserveTagsController < Manager::ApplicationController
  before_action :authenticate_user!
  before_action :confirm_current_reserve_manager!, unless: -> { super_admin? }
  before_action :is_administrator!, only: [:create], unless: -> { super_admin? }

  layout "manager"

  def new
    @presenter = Manager::ReserveInfo::ReserveTagsNewPresenter.new(reserve: current_reserve)
  end

  def create
    form = ReserveTagForm.new(
      reserve: current_reserve,
      reserve_tags: difference_of_hashes(params["tag_names"], reserve_tags_by_categories)
    )

    if form.save
      @presenter = Manager::ReserveInfo::ReserveTagsNewPresenter.new(reserve: current_reserve)
      flash.now[:notice] = I18n.t(".manager.reserve_info.reserve_tags.create.reserve_tags_updated")
      render :new
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def reserve_tags_by_categories
    swap_keys_values(current_reserve.reserve_tags.pluck(:name, :category))
  end

  def swap_keys_values(hash)
    hash.each_with_object({}) do |(k,v), h|
      if h.has_key?(v)
        h[v] << k
      else
        h[v] = [k]
      end
    end
  end

  def difference_of_hashes(hash1, hash2)
    diff_hash = {}

    hash1.each do |key, value|
      if hash2.key?(key)
        diff_hash[key] = (value - hash2[key]) + (hash2[key] - value)
      else
        diff_hash[key] = value
      end
    end

    (hash2.keys - hash1.keys).each do |key|
      diff_hash[key] = hash2[key]
    end

    diff_hash
  end
end
