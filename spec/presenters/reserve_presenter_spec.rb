require "rails_helper"

RSpec.describe ReservePresenter do
  describe "delegations" do
    subject { ReservePresenter.new(build(:reserve)) }
    it { is_expected.to delegate_method(:id).to(:reserve) }
    it { is_expected.to delegate_method(:name).to(:reserve) }
    it { is_expected.to delegate_method(:reserve_alert_message).to(:reserve) }
    it { is_expected.to delegate_method(:directions).to(:reserve) }
    it { is_expected.to delegate_method(:rules).to(:reserve) }
    it { is_expected.to delegate_method(:rules_url).to(:reserve) }
    it { is_expected.to delegate_method(:address_line_1).to(:reserve) }
    it { is_expected.to delegate_method(:address_line_2).to(:reserve) }
    it { is_expected.to delegate_method(:address_city).to(:reserve) }
    it { is_expected.to delegate_method(:address_postal_code).to(:reserve) }
    it { is_expected.to delegate_method(:State).to(:reserve) }
    it { is_expected.to delegate_method(:Country).to(:reserve) }
    it { is_expected.to delegate_method(:reserve_avatar).to(:reserve) }
    it { is_expected.to delegate_method(:image_placeholder).to(:reserve) }
    it { is_expected.to delegate_method(:managing_campus).to(:reserve) }
    it { is_expected.to delegate_method(:description).to(:reserve) }
  end
end
