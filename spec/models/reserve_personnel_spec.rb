require "rails_helper"

RSpec.describe ReservePersonnel, type: :model do
  describe "validations" do
    subject { build(:reserve_personnel) }
    it { is_expected.to validate_presence_of(:reserve) }
    it { is_expected.to validate_presence_of(:user) }
    it { is_expected.to validate_uniqueness_of(:user).scoped_to(:reserve_id) }
    it { is_expected.to validate_booleanish_values(:receive_new_visit_email) }
    it { is_expected.to validate_booleanish_values(:receive_incomplete_visit_email) }
    it { is_expected.to validate_booleanish_values(:receive_update_email) }
    it { is_expected.to validate_booleanish_values(:receive_approval_email) }
    it { is_expected.to validate_booleanish_values(:receive_iacuc_email) }
    it { is_expected.to validate_booleanish_values(:receive_drone_email) }
    it { is_expected.to validate_booleanish_values(:receive_scuba_email) }
  end

  describe "associations" do
    it { is_expected.to have_one_attached(:avatar_old) }
    it { is_expected.to belong_to(:reserve) }
    it { is_expected.to belong_to(:user) }
  end

  describe ".receiving_new_visit_email" do
    it "returns all reserve personnel records with receive_new_visit_email set to true" do
      personnel1 = create(:reserve_personnel, receive_new_visit_email: false)
      personnel2 = create(:reserve_personnel, receive_new_visit_email: true)
      personnel3 = create(:reserve_personnel, receive_new_visit_email: false)
      personnel4 = create(:reserve_personnel, receive_new_visit_email: true)

      results = ReservePersonnel.receiving_new_visit_email

      expect(results).to match_array [personnel2, personnel4]
    end
  end

  describe ".receiving_new_visit_or_update_email" do
    it "returns personnel receiving either the new visit or the update email" do
      new_visit_only = create(:reserve_personnel, receive_new_visit_email: true, receive_update_email: false)
      update_only = create(:reserve_personnel, receive_new_visit_email: false, receive_update_email: true)
      both = create(:reserve_personnel, receive_new_visit_email: true, receive_update_email: true)
      create(:reserve_personnel, receive_new_visit_email: false, receive_update_email: false)

      results = ReservePersonnel.receiving_new_visit_or_update_email

      expect(results).to match_array [new_visit_only, update_only, both]
    end
  end

  describe "#avatar_src" do
    it "presents placeholder image if no avatar is attached" do
      reserve_personnel = build(:reserve_personnel)

      avatar_src = reserve_personnel.avatar_src

      expect(avatar_src).to eq("personnel_avatar_placeholder.png")
    end

    it "presents the correct avatar_src path if avatar is attached" do
      reserve_personnel = create(:reserve_personnel, :with_avatar)

      avatar_src = reserve_personnel.avatar_src

      expect(avatar_src).to match(/medium_test-image.jpeg/)
    end
  end

  describe ".visible" do
    it "returns only personnel that have visible flag true" do
      personnel1 = create(:reserve_personnel, visible: false)
      personnel2 = create(:reserve_personnel, visible: true)
      personnel3 = create(:reserve_personnel, visible: false)
      personnel4 = create(:reserve_personnel, visible: true)

      results = ReservePersonnel.visible

      expect(results).to match_array [personnel2, personnel4]
    end
  end
end
