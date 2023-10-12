require "rails_helper"

RSpec.describe Home::LatestNews::IndexPresenter do
  describe "#news_articles" do
    it "returns latest news" do
      article_response = [
        {
          "title" => { "rendered" => "title 1" },
          "link" => "link 1",
          "_links"=> { "wp:featuredmedia" => ["href" => "https"], }
        },
        {
          "title" => { "rendered" => "title 2" },
          "link" => "link 2",
          "_links"=> { "wp:featuredmedia" => ["href" => "https"], }
        },
        {
          "title" => { "rendered" => "title 3" },
          "link" => "link 3",
          "_links"=> { "wp:featuredmedia" => ["href" => "https"], }
        },
      ].to_json
      featured_media_response = {
        "media_details" => { "sizes" => { "medium_large" => { "source_url" => "href" } } }
      }.to_json
      getter = HttpGetter
      allow(getter).to(
        receive(:get)
          .with(hash_including(url: Home::LatestNews::IndexPresenter::LATEST_NEWS_URL))
          .and_return(OpenStruct.new(body: article_response))
      )
      allow(getter).to(
        receive(:get)
          .with(hash_including(url: "https"))
          .and_return(OpenStruct.new(body: featured_media_response))
      )
      presenter = Home::LatestNews::IndexPresenter.new(getter)

      news_articles = presenter.news_articles

      expect(news_articles.map(&:title)).to match_array ["title 1", "title 2", "title 3"]
    end
  end
end
