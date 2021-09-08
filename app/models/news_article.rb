class NewsArticle < Struct.new(:id, :headline, :image_url, :url)
  def self.fake
    [
      NewsArticle.new(1, "Land donation expands Burn Pinon Ridge Reserve", "fake-article-image-1.jpg", "/article1"),
      NewsArticle.new(2, "Historic Hastings buildings renewed", "fake-article-image-2.jpg", "/article2"),
      NewsArticle.new(3, "Thinning Valentine Camp’s forest to save it", "fake-article-image-3.jpg", "/article3"),
    ]
  end
end
