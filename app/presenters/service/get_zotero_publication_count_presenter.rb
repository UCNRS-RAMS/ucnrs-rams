# frozen_string_literal: true

class Service::GetZoteroPublicationCountPresenter
  ZOTERO_URL = "https://api.zotero.org/groups/"
  HEADERS = {
    "Zotero-API-Version": "3",
    "Zotero-API-Key": "fXVnV4ZyNyK3k2XSFkiLfiK4",
  }.freeze

  def initialize(getter = HttpGetter, reserve_id: nil)
    @getter = getter
    @reserve_id = reserve_id
  end

  def fetch_reserve
    name = fetch_reserve_name(@reserve_id)
    pub_count = fetch_reserve_pub_count(@reserve_id)

    { name: name, pub_count: pub_count } if name
  end

  private

  def fetch_reserve_name(id)
    response = @getter.get(
      url: "#{ZOTERO_URL}#{id}",
      headers: HEADERS,
    )

    JSON.parse(response.body)["data"]["name"] if response.success?
  rescue Faraday::ConnectionFailed
    nil
  end

  def fetch_reserve_pub_count(id)
    response = @getter.get(
      url: "#{ZOTERO_URL}#{id}/items/top",
      headers: HEADERS,
    )

    response.headers["total-results"] if response.success?
  rescue Faraday::ConnectionFailed
    nil
  end
end
