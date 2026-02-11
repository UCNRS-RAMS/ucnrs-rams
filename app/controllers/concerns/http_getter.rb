class HttpGetter
  require "faraday"

  ConnectionError = Class.new(StandardError)

  Response = Struct.new(:success?, :body, :headers, keyword_init: true)

  def self.get(url: nil, params: nil, headers: nil)
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
  rescue Faraday::ConnectionFailed => e
    raise ConnectionError, e.message
  end

  private

  def connection
    Faraday.new(
      url: @url,
      params: @params,
      headers: @headers,
    )
  end
end
