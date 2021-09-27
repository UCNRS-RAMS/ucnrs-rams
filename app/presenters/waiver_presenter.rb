class WaiverPresenter
  def initialize(waiver)
    @waiver = waiver
  end

  delegate :id, :name, :description, :pdf_link, to: :waiver

  private

  attr_reader :waiver
end
