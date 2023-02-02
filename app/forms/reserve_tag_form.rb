class ReserveTagForm
  include ActiveModel::Model

  def model_name
    ActiveModel::Name.new(ReserveTag)
  end

  def initialize(reserve:, reserve_tags: {})
    @reserve = reserve
    @reserve_tags = reserve_tags
  end

  attr_reader :reserve_tags, :reserve

  delegate :valid?, :validate, :errors, to: :reserve_tag
  delegate_missing_to :reserve_tag

  def save
    begin
      reserve_tags.each do |category, tag_names|
        tag_names.each do |tag_name|
          if has_reserve_tag?(category, tag_name)
            delete_reserve_tag(category, tag_name)
          else
            reserve.reserve_tags.create(category: category, name: tag_name)
          end
        end
      end
      true
    rescue ActiveRecord::RecordInvalid => e
      Rails.logger.error(e)
      false
    end
  end

  private

  def delete_reserve_tag(category, tag_name)
    reserve.reserve_tags.with_name(category, tag_name).first.destroy
  end

  def has_reserve_tag?(category, tag_name)
    reserve.reserve_tags.with_name(category, tag_name).present?
  end
end
