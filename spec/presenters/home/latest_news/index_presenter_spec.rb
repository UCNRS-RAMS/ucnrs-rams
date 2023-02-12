require "rails_helper"

RSpec.describe Home::LatestNews::IndexPresenter do
  describe "#news_articles" do
    it "returns latest news" do
      articles = OpenStruct.new(
        body: [
          {
            "title" => {
              "rendered" => "title 1"
            },
            "link" => "link 1",
            "uagb_featured_image_src"=> {
              "medium_large" => ["image 1"],
            }
          },
          {
            "title" => {
              "rendered" => "title 2"
            },
            "link" => "link 2",
            "uagb_featured_image_src"=> {
              "medium_large" => ["image 2"],
            }
          },
          {
            "title" => {
              "rendered" => "title 3"
            },
            "link" => "link 3",
            "uagb_featured_image_src"=> {
              "medium_large" => ["image 3"],
            }
          },
        ]
      )
      getter = HttpGetter
      allow(getter).to receive(:get).and_return(articles)
      presenter = Home::LatestNews::IndexPresenter.new(getter)

      news_articles = presenter.news_articles

      expect(news_articles.map(&:title)).to match_array ["title 1", "title 2", "title 3"]
    end
  end
end
