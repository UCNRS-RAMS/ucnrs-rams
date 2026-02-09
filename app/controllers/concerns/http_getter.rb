class HttpGetter
  require "faraday"

  def self.get(url: nil, params: nil, headers: nil)
    new(url: url, params: params, headers: headers).get
  end

  def initialize(url:, params: nil, headers: nil)
    @url = url
    @params = params
    @headers = headers
  end

  def get
    connection.get
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
