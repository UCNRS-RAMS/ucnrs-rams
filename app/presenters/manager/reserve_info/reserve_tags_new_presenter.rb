class Manager::ReserveInfo::ReserveTagsNewPresenter
  def initialize(reserve:)
    @reserve = reserve
  end

  attr_reader :reserve

  def reserve_tags
    reserve_tags = Set.new(ReserveTag.where(reserve_id: reserve.id).pluck(:name))
    reserve_tags_hash = ReserveTag.pluck(:name, :category).to_h
    reserve_tags_hash
      .keys
      .group_by { |tag| reserve_tags_hash[tag] }
      .transform_values do |tags|
        tags.map { |tag| { name: tag, value: reserve_tags.include?(tag) } }
      end
  end
end
