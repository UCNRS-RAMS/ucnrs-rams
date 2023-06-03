class Home::LatestNews::IndexPresenter
  LATEST_NEWS_URL = 'https://ucnrs.org/wp-json/wp/v2/posts'.freeze
  NUM_OF_NEWS = 3
  DEFAULT_IMG = "fake-article-image-1.jpg"

  def initialize(getter)
    @getter = getter
  end

  def news_articles
    body.each.map do |article|
      OpenStruct.new(
        title: article.title&.rendered,
        link: article.link,
        image: article.uagb_featured_image_src&.medium_large&.first || DEFAULT_IMG
      )
    end
  end

  private

  attr_reader :getter

  def response
    @response ||= getter.get(url: LATEST_NEWS_URL, params: { per_page: NUM_OF_NEWS })
  end

  def body
    @body ||= JSON.parse(response.body, object_class: OpenStruct)
  end
end
