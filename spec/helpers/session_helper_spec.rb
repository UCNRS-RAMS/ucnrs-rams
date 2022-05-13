require "rails_helper"

RSpec.describe SessionHelper, type: :helper do
  describe "#current_reserve" do
    it "returns reserve that correspond to reserve_id param" do
      reserve = create(:reserve, id: 5, name: "5 Llamas Reserve")
      params[:reserve_id] = 5

      expect(current_reserve).to eq(reserve)
    end
  end
end
