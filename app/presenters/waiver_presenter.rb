class WaiverPresenter
  def initialize(waiver)
    @waiver = waiver
  end

  delegate :id, :name, :description, :url, :url_type, to: :waiver

  def url?
    url.present?
  end

  def link_text
    url_type == "link" ? I18n.t(".reserves.waivers.waiver.show_more") : I18n.t(".reserves.waivers.waiver.download_pdf")
  end

  def link_class
    url_type == "link" ? "icon-external-link" : "icon-document-a"
  end

  private

  attr_reader :waiver
end
