require "rails_helper"

RSpec.describe Manager::ReserveInfo::ReserveAddendumsController, type: :request do
  let(:reserve) { create(:reserve) }
  let(:manager) do
    user = create(:user, :confirmed)
    create(:reserve_personnel, user: user, reserve: reserve)
    user
  end

  let(:turbo_stream_headers) { { "Accept" => "text/vnd.turbo-stream.html, text/html" } }

  def index_path
    "/manager/reserves/#{reserve.id}/reserve_info/reserve_addendums"
  end

  describe "GET reserve addendums index" do
    it "renders the addendums table for a reserve manager" do
      create(:reserve_addendum, reserve: reserve, sort_order: 10, name: "existing addendum")
      sign_in(manager)

      get index_path

      expect(response).to be_ok
      page = Capybara.string(response.body)
      expect(page).to have_css("turbo-frame#reserve-addendums-table")
      expect(page).to have_css("table#reserve-addendums-table")
      expect(page).to have_content("existing addendum")
    end

    it "rejects a user who is not personnel of the reserve" do
      sign_in(create(:user, :confirmed))

      get index_path

      expect(response).to have_http_status(:redirect)
      expect(flash[:alert]).to eq(I18n.t("manager.not_a_manager_of_reserve"))
    end
  end

  describe "POST reserve addendums" do
    it "creates a reserve addendum and refreshes the addendums table" do
      sign_in(manager)

      expect {
        post index_path,
          params: {
            reserve_addendum: {
              sort_order: 100,
              name: "new addendum",
              content: "<div>new addendum content</div>"
            }
          },
          headers: turbo_stream_headers
      }.to change(ReserveAddendum, :count).by(1)

      addendum = reserve.addendums.last
      expect(addendum.sort_order).to eq(100)
      expect(addendum.name).to eq("new addendum")
      expect(addendum.content.to_plain_text).to eq("new addendum content")
      expect(response).to redirect_to(index_path)

      get index_path, headers: turbo_stream_headers

      expect(response.media_type).to eq("text/vnd.turbo-stream.html")
      page = Capybara.string(response.body)
      expect(page).to have_css('turbo-stream[action="replace"][target="modal-content"]')
      expect(page).to have_css('turbo-stream[action="replace"][target="reserve-addendums-table"]')
      expect(response.body).to include("new addendum")
    end

    it "re-renders the new addendum modal when the addendum is invalid" do
      sign_in(manager)

      expect {
        post index_path,
          params: { reserve_addendum: { sort_order: 100, name: "" } },
          headers: turbo_stream_headers
      }.not_to change(ReserveAddendum, :count)

      expect(response).to have_http_status(:unprocessable_content)
      page = Capybara.string(response.body)
      expect(page).to have_css('turbo-stream[action="update"][target="modal-content"]')
      expect(response.body).to include("reserve_addendum[name]")
    end

    it "rejects a user who is not personnel of the reserve" do
      sign_in(create(:user, :confirmed))

      expect {
        post index_path,
          params: { reserve_addendum: { sort_order: 100, name: "not allowed" } }
      }.not_to change(ReserveAddendum, :count)

      expect(response).to have_http_status(:redirect)
      expect(flash[:alert]).to eq(I18n.t("manager.not_a_manager_of_reserve"))
    end
  end

  describe "PATCH reserve addendum" do
    let!(:addendum) do
      create(:reserve_addendum, reserve: reserve, sort_order: 10, name: "old addendum name")
    end

    it "updates the reserve addendum and refreshes the addendums table" do
      sign_in(manager)

      patch "/manager/reserves/#{reserve.id}/reserve_info/reserve_addendums/#{addendum.id}",
        params: {
          reserve_addendum: {
            sort_order: 100,
            name: "new addendum",
            content: "<div>new addendum content</div>"
          }
        },
        headers: turbo_stream_headers

      expect(response).to redirect_to(index_path)

      addendum.reload
      expect(addendum.sort_order).to eq(100)
      expect(addendum.name).to eq("new addendum")
      expect(addendum.content.to_plain_text).to eq("new addendum content")

      get index_path, headers: turbo_stream_headers

      page = Capybara.string(response.body)
      expect(page).to have_css('turbo-stream[action="replace"][target="reserve-addendums-table"]')
      expect(response.body).to include("new addendum")
      expect(response.body).not_to include("old addendum name")
    end

    it "re-renders the edit addendum modal when the addendum is invalid" do
      create(:reserve_addendum, reserve: reserve, sort_order: 20, name: "another addendum")
      sign_in(manager)

      patch "/manager/reserves/#{reserve.id}/reserve_info/reserve_addendums/#{addendum.id}",
        params: { reserve_addendum: { sort_order: 20, name: "duplicate order" } },
        headers: turbo_stream_headers

      expect(response).to have_http_status(:unprocessable_content)
      page = Capybara.string(response.body)
      expect(page).to have_css('turbo-stream[action="update"][target="modal-content"]')

      expect(addendum.reload.name).to eq("old addendum name")
    end

    it "rejects a user who is not personnel of the reserve" do
      sign_in(create(:user, :confirmed))

      patch "/manager/reserves/#{reserve.id}/reserve_info/reserve_addendums/#{addendum.id}",
        params: { reserve_addendum: { name: "not allowed" } }

      expect(response).to have_http_status(:redirect)
      expect(flash[:alert]).to eq(I18n.t("manager.not_a_manager_of_reserve"))
      expect(addendum.reload.name).to eq("old addendum name")
    end
  end
end
