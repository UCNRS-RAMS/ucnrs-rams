class Home::LatestNews::IndexPresenter
  LATEST_NEWS_URL = 'https://ucnrs.org/wp-json/wp/v2/posts'.freeze
  NUM_OF_NEWS = 3
  DEFAULT_IMG = "fake-article-image-1.jpg".freeze

  def initialize(getter)
    @getter = getter
  end

  def news_articles
    response = get_response url: LATEST_NEWS_URL, params: { per_page: NUM_OF_NEWS }
    articles = json_to_object(response.body)

    articles. each.map do |article|
      response = get_response url: article._links["wp:featuredmedia"].first.href
      featured_media = json_to_object(response.body)

      OpenStruct.new(
        title: article.title&.rendered,
        link: article.link,
        image: featured_media&.media_details&.sizes&.medium_large&.source_url || DEFAULT_IMG
      )
    end
  end

  private

  attr_reader :getter

  def get_response(url: nil, params: nil)
    getter.get(url: url, params: params)
  end

  def json_to_object(json)
    JSON.parse(json, object_class: OpenStruct)
  end
end
