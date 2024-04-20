require "rails_helper"

RSpec.describe ReservePersonnelPresenter do
  describe "delegations" do
    subject { ReservePersonnelPresenter.new(build(:reserve_personnel)) }
    it { is_expected.to delegate_method(:id).to(:reserve_personnel) }
    it { is_expected.to delegate_method(:role_title).to(:reserve_personnel) }
    it { is_expected.to delegate_method(:email).to(:reserve_personnel) }
    it { is_expected.to delegate_method(:phone_number).to(:reserve_personnel) }
    it { is_expected.to delegate_method(:user).to(:reserve_personnel) }
    it { is_expected.to delegate_method(:avatar_src).to(:reserve_personnel) }
  end

  describe "#full_name" do
    it "presents reserve personnel full name" do
      user = create(:user, first_name: "mr", last_name: "atoz")
      reserve_personnel = create(:reserve_personnel, user: user)

      presenter = ReservePersonnelPresenter.new(reserve_personnel)
      expect(presenter.full_name).to eq "mr atoz"
    end
  end
end
