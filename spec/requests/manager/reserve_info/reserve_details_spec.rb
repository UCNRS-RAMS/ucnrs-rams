require "rails_helper"

RSpec.describe "Manager - Reserve Info - Reserve Details", type: :request do
  let(:reserve) { create(:reserve) }
  let(:manager) do
    user = create(:user, :confirmed)
    create(:reserve_personnel, user: user, reserve: reserve)
    user
  end

  let(:turbo_stream_headers) { { "Accept" => "text/vnd.turbo-stream.html, text/html" } }

  def reserve_details_path
    "/manager/reserves/#{reserve.id}/reserve_info/reserve_details"
  end

  def amenities_and_rates_path
    "/manager/reserves/#{reserve.id}/reserve_info/amenities_and_rates"
  end

  describe "PATCH reserve details" do
    it "updates the amenity group labels" do
      sign_in(manager)

      patch reserve_details_path,
        params: {
          reserve: {
            amenity_group_label_1: "new label 1",
            amenity_group_label_2: "new label 2",
            amenity_group_label_3: "new label 3",
            amenity_group_label_4: "new label 4",
            amenity_group_label_5: "new label 5"
          }
        },
        headers: turbo_stream_headers

      expect(response).to be_ok
      page = Capybara.string(response.body)
      expect(page).to have_css('turbo-stream[action="replace"][target="flash"]')
      expect(page).to have_css('turbo-stream[action="update"][target="reserve-details-edit-form-container"]')
      expect(response.body).to include("Update success.")

      reserve.reload
      expect(reserve.amenity_group_label_1).to eq("new label 1")
      expect(reserve.amenity_group_label_2).to eq("new label 2")
      expect(reserve.amenity_group_label_3).to eq("new label 3")
      expect(reserve.amenity_group_label_4).to eq("new label 4")
      expect(reserve.amenity_group_label_5).to eq("new label 5")
    end

    it "attaches listing and large hero photos to the reserve" do
      sign_in(manager)
      image = Rack::Test::UploadedFile.new(
        Rails.root.join("spec/support/assets/test-image.jpeg"),
        "image/jpeg",
      )

      patch reserve_details_path,
        params: {
          reserve: {
            listing_photo: image,
            large_hero_photo: image
          }
        },
        headers: turbo_stream_headers

      expect(response).to be_ok

      reserve.reload
      expect(reserve.listing_photo_url).to match(%r{/listing_photo/test-image.jpeg})
      expect(reserve.large_hero_photo_url).to match(%r{/large_hero_photo/test-image.jpeg})
    end

    it "rejects a user who is not personnel of the reserve" do
      sign_in(create(:user, :confirmed))

      patch reserve_details_path,
        params: { reserve: { amenity_group_label_1: "not allowed" } }

      expect(response).to have_http_status(:redirect)
      expect(flash[:alert]).to eq(I18n.t("manager.not_a_manager_of_reserve"))
      expect(reserve.reload.amenity_group_label_1).not_to eq("not allowed")
    end
  end

  describe "GET amenities and rates index" do
    it "renders the amenities, rate categories and rates tables" do
      create(:amenity, reserve: reserve, title: "Existing amenity")
      sign_in(manager)

      get amenities_and_rates_path

      expect(response).to be_ok
      page = Capybara.string(response.body)
      expect(page).to have_css("turbo-frame#amenities-table")
      expect(page).to have_css("turbo-frame#amenity-rate-categories-table")
      expect(page).to have_css("turbo-frame#amenity-rates-table")
      expect(page).to have_content("Existing amenity")
    end

    it "rejects a user who is not personnel of the reserve" do
      sign_in(create(:user, :confirmed))

      get amenities_and_rates_path

      expect(response).to have_http_status(:redirect)
      expect(flash[:alert]).to eq(I18n.t("manager.not_a_manager_of_reserve"))
    end
  end

  describe "POST amenities" do
    it "creates an amenity and refreshes the amenities table" do
      sign_in(manager)

      expect {
        post "/manager/reserves/#{reserve.id}/reserve_info/amenities",
          params: {
            amenity: {
              title: "Kayak",
              group_number: "1",
              units_type: "facility",
              time_type: "day",
              sort_order: 10,
              visible: "true",
              disable: "false"
            }
          },
          headers: turbo_stream_headers
      }.to change(Amenity, :count).by(1)

      amenity = reserve.amenities.last
      expect(amenity.title).to eq("Kayak")
      expect(amenity.group_number).to eq("1")
      expect(amenity.units_type).to eq("facility")
      expect(amenity.time_type).to eq("day")
      expect(amenity.sort_order).to eq(10)
      expect(flash[:notice]).to be_present
      expect(response).to redirect_to(amenities_and_rates_path)

      get amenities_and_rates_path, headers: turbo_stream_headers

      page = Capybara.string(response.body)
      expect(page).to have_css('turbo-stream[action="replace"][target="amenities-table"]')
      expect(response.body).to include("Kayak")
    end

    it "re-renders the new amenity modal when the amenity is invalid" do
      sign_in(manager)

      expect {
        post "/manager/reserves/#{reserve.id}/reserve_info/amenities",
          params: { amenity: { title: "", group_number: "1", units_type: "", time_type: "" } },
          headers: turbo_stream_headers
      }.not_to change(Amenity, :count)

      expect(response).to have_http_status(:unprocessable_content)
      page = Capybara.string(response.body)
      expect(page).to have_css('turbo-stream[action="update"][target="modal-content"]')
      expect(response.body).to include("amenity[title]")
    end

    it "rejects a user who is not personnel of the reserve" do
      sign_in(create(:user, :confirmed))

      expect {
        post "/manager/reserves/#{reserve.id}/reserve_info/amenities",
          params: {
            amenity: {
              title: "not allowed",
              group_number: "1",
              units_type: "facility",
              time_type: "day"
            }
          }
      }.not_to change(Amenity, :count)

      expect(response).to have_http_status(:redirect)
      expect(flash[:alert]).to eq(I18n.t("manager.not_a_manager_of_reserve"))
    end
  end

  describe "PATCH amenity" do
    it "updates the amenity and refreshes the amenities table" do
      amenity = create(:amenity, reserve: reserve, title: "Old title")
      sign_in(manager)

      patch "/manager/reserves/#{reserve.id}/reserve_info/amenities/#{amenity.id}",
        params: { amenity: { title: "New title", group_number: "2", sort_order: 20 } },
        headers: turbo_stream_headers

      expect(response).to redirect_to(amenities_and_rates_path)
      expect(flash[:notice]).to be_present

      amenity.reload
      expect(amenity.title).to eq("New title")
      expect(amenity.group_number).to eq("2")
      expect(amenity.sort_order).to eq(20)

      get amenities_and_rates_path, headers: turbo_stream_headers

      page = Capybara.string(response.body)
      expect(page).to have_css('turbo-stream[action="replace"][target="amenities-table"]')
      expect(response.body).to include("New title")
    end

    it "re-renders the edit amenity modal when the amenity is invalid" do
      amenity = create(:amenity, reserve: reserve, title: "Old title")
      sign_in(manager)

      patch "/manager/reserves/#{reserve.id}/reserve_info/amenities/#{amenity.id}",
        params: { amenity: { title: "" } },
        headers: turbo_stream_headers

      expect(response).to have_http_status(:unprocessable_content)
      page = Capybara.string(response.body)
      expect(page).to have_css('turbo-stream[action="update"][target="modal-content"]')
      expect(amenity.reload.title).to eq("Old title")
    end
  end

  describe "PATCH amenity rates" do
    it "updates the rate for the amenity" do
      amenity = create(:amenity, reserve: reserve)
      amenity_rate = create(:amenity_rate, amenity: amenity, rate: 12.50)
      sign_in(manager)

      patch "/manager/reserves/#{reserve.id}/reserve_info/amenity_rates/#{amenity.id}",
        params: {
          amenity: {
            amenity_rates_attributes: {
              "0" => { id: amenity_rate.id, rate: "99.99" }
            }
          }
        },
        headers: turbo_stream_headers

      expect(response).to redirect_to(amenities_and_rates_path)
      expect(flash[:notice]).to be_present
      expect(amenity_rate.reload.rate.to_s).to eq("99.99")

      get amenities_and_rates_path, headers: turbo_stream_headers

      page = Capybara.string(response.body)
      expect(page).to have_css('turbo-stream[action="replace"][target="amenity-rates-table"]')
      expect(response.body).to include("99.99")
    end

    it "re-renders the edit rates modal when the rate is invalid" do
      amenity = create(:amenity, reserve: reserve)
      amenity_rate = create(:amenity_rate, amenity: amenity, rate: 12.50)
      sign_in(manager)

      patch "/manager/reserves/#{reserve.id}/reserve_info/amenity_rates/#{amenity.id}",
        params: {
          amenity: {
            amenity_rates_attributes: {
              "0" => { id: amenity_rate.id, rate: "" }
            }
          }
        },
        headers: turbo_stream_headers

      expect(response).to have_http_status(:unprocessable_content)
      page = Capybara.string(response.body)
      expect(page).to have_css('turbo-stream[action="update"][target="modal-content"]')
      expect(amenity_rate.reload.rate.to_s).to eq("12.5")
    end

    it "rejects a user who is not personnel of the reserve" do
      amenity = create(:amenity, reserve: reserve)
      amenity_rate = create(:amenity_rate, amenity: amenity, rate: 12.50)
      sign_in(create(:user, :confirmed))

      patch "/manager/reserves/#{reserve.id}/reserve_info/amenity_rates/#{amenity.id}",
        params: {
          amenity: {
            amenity_rates_attributes: {
              "0" => { id: amenity_rate.id, rate: "99.99" }
            }
          }
        }

      expect(response).to have_http_status(:redirect)
      expect(flash[:alert]).to eq(I18n.t("manager.not_a_manager_of_reserve"))
      expect(amenity_rate.reload.rate.to_s).to eq("12.5")
    end
  end
end
