require "rails_helper"

RSpec.describe InstitutionsController, type: :request do
  let(:institution_params) do
    country = create(:country)
    state = create(:state, country: country)

    {
      name: "Bodega Marine Laboratory",
      city: "Bodega Bay",
      institution_type: :university_of_california,
      country_id: country.id,
      state_id: state.id,
    }
  end

  describe "GET /institutions/new" do
    it "renders the modal frame for a turbo frame request" do
      sign_in(create(:user, :confirmed))

      get "/institutions/new", headers: { "Turbo-Frame" => "modal-content" }

      expect(response).to be_ok

      doc = Capybara.string(response.body)
      expect(doc).to have_css("turbo-frame#modal-content")
    end
  end

  describe "POST /institutions" do
    it "closes the modal and backfills the user institution field" do
      sign_in(create(:user, :confirmed))

      post "/institutions",
        params: { institution: institution_params },
        headers: { "Accept" => "text/vnd.turbo-stream.html, text/html" }

      expect(response).to be_ok
      expect(response.media_type).to eq("text/vnd.turbo-stream.html")

      institution = Institution.find_by(name: "Bodega Marine Laboratory")
      expect(institution).to be_present

      doc = Capybara.string(response.body)
      expect(doc).to have_css('turbo-stream[action="replace"][target="modal-content"]')
      expect(doc).to have_css('turbo-stream[action="replace"][target="flash"]')

      name_stream = Nokogiri::HTML.fragment(response.body)
        .at_css('turbo-stream[action="set_value"][targets="#user_institution"]')
      id_stream = Nokogiri::HTML.fragment(response.body)
        .at_css('turbo-stream[action="set_value"][targets="#user_institution_id"]')

      expect(name_stream["value"]).to eq("Bodega Marine Laboratory")
      expect(id_stream["value"]).to eq(institution.id.to_s)
    end

    it "re-renders the modal frame on failure so the form stays open" do
      sign_in(create(:user, :confirmed))

      post "/institutions",
        params: { institution: { name: "", city: "", institution_type: "" } },
        headers: { "Accept" => "text/vnd.turbo-stream.html, text/html" }

      expect(response).to have_http_status(:unprocessable_content)

      doc = Capybara.string(response.body)
      expect(doc).to have_css("turbo-frame#modal-content")
      expect(doc).to have_css("form[action='/institutions']")
      expect(doc).to have_css("label.error")
    end
  end
end
