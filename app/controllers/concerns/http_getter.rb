require 'faraday'

class HttpGetter
  def self.get(url: nil, params: nil)
    new(url: url, params: params).get
  end

  def initialize(url:, params: nil)
    @url = url
    @params = params
  end

  def get
    connection.get
  end

  private

  def connection
    Faraday.new(
      url: @url,
      params: @params,
    )
  end
end
