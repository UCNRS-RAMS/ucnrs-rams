require "rails_helper"

RSpec.describe NewsArticlePresenter do
  describe "delegations" do
    subject { NewsArticlePresenter.new(NewsArticle.new(1, "Hi", "url", "url")) }
    it { is_expected.to delegate_method(:id).to(:news_article) }
    it { is_expected.to delegate_method(:headline).to(:news_article) }
    it { is_expected.to delegate_method(:image_url).to(:news_article) }
    it { is_expected.to delegate_method(:url).to(:news_article) }
  end
end
