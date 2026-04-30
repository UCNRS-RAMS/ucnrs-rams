RSpec.configure do |config|
  config.before(:each, type: :system) do
    allow(HttpGetter).to receive(:get) do |url:, **|
      raise "Unstubbed HttpGetter.get for #{url.inspect} — add a stub in your spec " \
            "or in spec/support/stub_http_getter.rb"
    end

    article_response = [
      {
        "title" => { "rendered" => "Stubbed news title" },
        "link" => "https://example.test/news/1",
        "_links" => { "wp:featuredmedia" => [{ "href" => "https://example.test/media/1" }] },
      },
    ].to_json

    featured_media_response = {
      "media_details" => {
        "sizes" => { "medium_large" => { "source_url" => "https://example.test/img.jpg" } },
      },
    }.to_json

    allow(HttpGetter).to receive(:get)
      .with(hash_including(url: Home::LatestNews::IndexPresenter::LATEST_NEWS_URL))
      .and_return(HttpGetter::Response.new("success?": true, body: article_response, headers: {}))

    allow(HttpGetter).to receive(:get)
      .with(hash_including(url: "https://example.test/media/1"))
      .and_return(HttpGetter::Response.new("success?": true, body: featured_media_response, headers: {}))
  end
end
