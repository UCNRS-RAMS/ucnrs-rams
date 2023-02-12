class Home::LatestNews::IndexPresenter
  LATEST_NEWS_URL = 'https://ucnrs.org/wp-json/wp/v2/posts'.freeze
  NUM_OF_NEWS = 3

  def initialize(getter)
    @getter = getter
  end

  def news_articles
    NUM_OF_NEWS.times.map do |i|
      OpenStruct.new(
        title: response.body[i]["title"]["rendered"],
        link: response.body[i]["link"],
        image: response.body[i]["uagb_featured_image_src"]["medium_large"][0]
      )
    end
  end

  private

  attr_reader :getter

  def response
    @response ||= getter.get(url: LATEST_NEWS_URL, params: { per_page: NUM_OF_NEWS })
  end
end
