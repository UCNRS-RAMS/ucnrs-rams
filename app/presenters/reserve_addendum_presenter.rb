class ReserveAddendumPresenter
  def initialize(reserve_addendum)
    @reserve_addendum = reserve_addendum
  end

  delegate :id,
    :sort_order,
    :url_link,
    :url_text,
    :subject,
    :info_text,
    :info_format,
    to: :reserve_addendum

  private

  attr_reader :reserve_addendum
end
