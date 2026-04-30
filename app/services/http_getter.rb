class HttpGetter
  require "faraday"

  OPEN_TIMEOUT = 5
  TIMEOUT = 10

  ConnectionError = Class.new(StandardError)

  Response = Struct.new(:success?, :body, :headers, keyword_init: true)

  def self.get(url:, params: nil, headers: nil)
    new(url: url, params: params, headers: headers).get
  end

  def initialize(url:, params: nil, headers: nil)
    @url = url
    @params = params
    @headers = headers
  end

  def get
    raw = connection.get
    Response.new(
      "success?": raw.success?,
      body: raw.body,
      headers: raw.headers,
    )
  rescue Faraday::Error => e
    raise ConnectionError, e.message
  end

  private

  def connection
    Faraday.new(
      url: @url,
      params: @params,
      headers: @headers,
      request: { open_timeout: OPEN_TIMEOUT, timeout: TIMEOUT },
    )
  end
end
