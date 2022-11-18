require "rails_helper"

RSpec.describe Manager::UserEditPresenter do
  describe "delegations" do
    subject { Manager::UserEditPresenter.new(build(:user)) }
    it { is_expected.to delegate_method(:id).to(:form_user).with_prefix(:user) }
    it { is_expected.to delegate_method(:full_name).to(:form_user).with_prefix(:user) }
    it { is_expected.to delegate_method(:institution).to(:form_user).with_prefix(:user) }
    it { is_expected.to delegate_method(:name).to(:user_institution).with_prefix(true) }
  end
end
