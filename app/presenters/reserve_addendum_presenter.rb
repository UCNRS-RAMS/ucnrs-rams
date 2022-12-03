class ReserveAddendumPresenter
  def initialize(reserve_addendum)
    @reserve_addendum = reserve_addendum
  end

  delegate :id,
    :sort_order,
    :name,
    :content,
    :to_key,
    :model_name,
    to: :reserve_addendum

  private

  attr_reader :reserve_addendum
end
