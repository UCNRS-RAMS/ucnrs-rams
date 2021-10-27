require "rails_helper"

RSpec.describe ReservePersonnelPresenter do
  include Rails.application.routes.url_helpers
  describe "delegations" do
    subject { ReservePersonnelPresenter.new(build(:reserve_personnel)) }
    it { is_expected.to delegate_method(:id).to(:reserve_personnel) }
    it { is_expected.to delegate_method(:role).to(:reserve_personnel) }
    it { is_expected.to delegate_method(:email).to(:reserve_personnel) }
    it { is_expected.to delegate_method(:phone_number).to(:reserve_personnel) }
    it { is_expected.to delegate_method(:user).to(:reserve_personnel) }
    it { is_expected.to delegate_method(:user).to(:reserve_personnel) }
    it { is_expected.to delegate_method(:avatar).to(:reserve_personnel).with_prefix(true) }
  end

  describe "#full_name" do
    it "presents reserve personnel full name" do
      user = create(:user, first_name: "mr", last_name: "atoz")
      reserve_personnel = create(:reserve_personnel, user: user)

      presenter = ReservePersonnelPresenter.new(reserve_personnel)
      expect(presenter.full_name).to eq "mr atoz"
    end
  end

  describe "#avatar" do
    it "presents placeholder image if no avatar is attached" do
      reserve_personnel = build(:reserve_personnel)

      presenter = ReservePersonnelPresenter.new(reserve_personnel)
      expect(presenter.avatar).to eq "reserve_icon1.png"
    end
    
    it 'presents the correct avatar path if avatar is attached' do
      reserve_personnel = build(:reserve_personnel, :with_avatar)

      presenter = ReservePersonnelPresenter.new(reserve_personnel)
      expect(presenter.avatar).to eq rails_blob_path(reserve_personnel.avatar, only_path: true)
    end
  end
end
