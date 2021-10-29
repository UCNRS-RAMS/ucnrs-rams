class WaiverPresenter
  def initialize(waiver)
    @waiver = waiver
  end

  delegate :id, :name, :description, :url, to: :waiver

  def pdf_link
    url
  end

  private

  attr_reader :waiver
end
