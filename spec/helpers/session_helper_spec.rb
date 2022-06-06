require "rails_helper"

RSpec.describe SessionHelper, type: :helper do
  describe "#current_reserve" do
    it "returns reserve that correspond to reserve_id param" do
      reserve = create(:reserve, id: 5, name: "5 Llamas Reserve")
      params[:reserve_id] = 5

      expect(current_reserve).to eq(reserve)
    end
  end

  describe "#confirm_manager!" do
    it "returns true if current_user is a manager of the current_reserve" do
      user = build(:user)
      reserve = build(:reserve)
      allow(helper).to receive(:current_user).and_return(user)
      allow(helper).to receive(:current_reserve).and_return(reserve)
      create(:reserve_personnel, reserve: reserve, user: user)

      expect(helper.confirm_manager!).to eq true
    end
  end
end
