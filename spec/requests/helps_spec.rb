require 'rails_helper'

RSpec.describe "Helps", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/helps"
      expect(response).to have_http_status(:success)
    end
  end

end
