require "rails_helper"

RSpec.describe "Manager::ApplicationController#confirm_current_reserve_manager!", type: :request do
  def get_dashboard(reserve, headers: {})
    get "/manager/reserves/#{reserve.id}/dashboard", headers: headers
  end

  it "allows a manager of the current reserve through" do
    reserve = create(:reserve)
    manager = create(:user, :confirmed)
    create(:reserve_personnel, user: manager, reserve: reserve)
    sign_in(manager)

    get_dashboard(reserve)

    expect(response).to be_ok

    doc = Capybara.string(response.body)
    expect(doc).to have_css("body.manager.dashboard")
  end

  it "denies a user who manages no reserve" do
    reserve = create(:reserve)
    sign_in(create(:user, :confirmed))

    get_dashboard(reserve)

    expect(response).to redirect_to(root_url)
    expect(flash[:alert]).to eq(I18n.translate("manager.not_a_manager_of_reserve"))
  end

  it "denies a manager of a different reserve" do
    reserve = create(:reserve)
    other_reserve = create(:reserve)
    manager = create(:user, :confirmed)
    create(:reserve_personnel, user: manager, reserve: other_reserve)
    sign_in(manager)

    get_dashboard(reserve)

    expect(response).to redirect_to(root_url)
    expect(flash[:alert]).to eq(I18n.translate("manager.not_a_manager_of_reserve"))
  end

  it "renders the modal flash instead of redirecting for a turbo frame request" do
    reserve = create(:reserve)
    sign_in(create(:user, :confirmed))

    get_dashboard(reserve, headers: { "Turbo-Frame" => "modal-content" })

    expect(response).to have_http_status(:unprocessable_content)

    doc = Capybara.string(response.body)
    expect(doc).to have_css("turbo-frame#modal-content")
    expect(doc).to have_css("p.alert", text: I18n.translate("manager.not_a_manager_of_reserve"))
  end

  it "sends the user back where they came from when a referer is present" do
    reserve = create(:reserve)
    sign_in(create(:user, :confirmed))

    get_dashboard(reserve, headers: { "HTTP_REFERER" => "http://www.example.com/helps" })

    expect(response).to redirect_to("http://www.example.com/helps")
  end
end
