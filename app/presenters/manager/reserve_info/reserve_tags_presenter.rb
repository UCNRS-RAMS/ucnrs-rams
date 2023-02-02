class Manager::ReserveInfo::ReserveTagsPresenter
  def initialize(reserve:)
    @reserve = reserve
  end

  attr_reader :reserve

  def reserve_tags
    ReserveTag
    .pluck(:name, :category)
    .to_h
    .then do |reserve_tags| 
      reserve_tags
      .keys
      .group_by { |tag| reserve_tags[tag] }
    end
  end

  def has_reserve_tag?(category, tag_name)
    reserve.reserve_tags.with_name(category, tag_name).present?
  end

  private

  def reserve_scope
    Reserve
      .searching_term(search_filter)
      .with_names(selected_tags)
      .alphabetized
  end
end
