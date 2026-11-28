require "rails_helper"

RSpec.describe Manager::ReserveInfo::StaffAndNotificationsController, type: :request do
  describe "PATCH /manager/reserves/:reserve_id/reserve_info/staff_and_notifications/:id" do
    it "saves the contact request email setting" do
      user = create(:user, :confirmed)
      reserve = create(:reserve)
      create(:reserve_personnel, user: user, reserve: reserve)
      personnel = create(:reserve_personnel, reserve: reserve, receive_project_interest_email: false)
      sign_in(user)

      patch "/manager/reserves/#{reserve.id}/reserve_info/staff_and_notifications/#{personnel.id}", params: {
        reserve_personnel: { receive_project_interest_email: "1" }
      }

      expect(response).to redirect_to("/manager/reserves/#{reserve.id}/reserve_info/staff_and_notifications")
      expect(personnel.reload.receive_project_interest_email).to be true
    end
  end
end
