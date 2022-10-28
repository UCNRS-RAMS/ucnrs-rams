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
    it { is_expected.to have_one_attached(:avatar) }
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
end
