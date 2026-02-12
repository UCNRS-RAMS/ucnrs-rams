# frozen_string_literal: true

class Service::GetZoteroPublicationCountPresenter
  ZOTERO_URL = "https://api.zotero.org/groups/"
  HEADERS = {
    "Zotero-API-Version": "3",
    "Zotero-API-Key": "fXVnV4ZyNyK3k2XSFkiLfiK4",
  }.freeze

  def initialize(getter = HttpGetter, reserve_id: nil, item_type: nil)
    @getter = getter
    @reserve_id = reserve_id
    @item_type = item_type
  end

  def fetch_reserve
    name = fetch_reserve_name(@reserve_id)
    pub_count = fetch_reserve_pub_count(@reserve_id)

    { name: name, pub_count: pub_count }
  end

  private

  def fetch_reserve_name(id)
    response = @getter.get(
      url: "#{ZOTERO_URL}#{id}",
      headers: HEADERS,
    )

    JSON.parse(response.body).dig("data", "name") if response.success?
  rescue StandardError
    nil
  end

  def fetch_reserve_pub_count(id)
    url = "#{ZOTERO_URL}#{id}/items/top"
    url += "?itemType=#{@item_type}" if @item_type.present?

    response = @getter.get(
      url: url,
      headers: HEADERS,
    )

    response.headers["total-results"] if response.success?
  rescue StandardError
    nil
  end
end
