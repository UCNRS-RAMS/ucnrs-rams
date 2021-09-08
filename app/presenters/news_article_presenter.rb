class NewsArticlePresenter
  def initialize(news_article)
    @news_article = news_article
  end

  attr_reader :news_article

  delegate :id, :headline, :image_url, :url, to: :news_article
end
