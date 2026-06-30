# frozen_string_literal: true

class Service::GetZoteroPublicationCountPresenter
  # in the future (8.2) Rails.app.creds will handle both things from encrypted credentials and from environment passed in
  # with one interface but it's not out yet, so simply using the ENV for now.
  ZOTERO_URL = "https://api.zotero.org/groups/"
  HEADERS = {
    "Zotero-API-Version": "3",
    "Zotero-API-Key": ENV.fetch('ZOTERO_API_KEY', nil)
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
