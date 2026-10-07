require "rails_helper"

RSpec.describe "matomo", type: :view do
  before do
    allow(Rails.application.config.x).to receive(:matomo_enabled).and_return(matomo_enabled)
  end

  let(:matomo_enabled) { true }

  it "renders Matomo as a consent-controlled script when enabled" do
    render partial: "layouts/matomo"

    expect(rendered).to have_css('script[type="text/plain"][data-name="matomo-tracking"]')
    expect(rendered).to include("anonymizeIp")
    expect(rendered).not_to include("trackPageView")
    expect(rendered).to include("ramsMatomoLoaded")
  end

  context "when Matomo is disabled" do
    let(:matomo_enabled) { false }

    it "renders no tracking script" do
      render partial: "layouts/matomo"

      expect(rendered.strip).to be_empty
    end
  end
end
