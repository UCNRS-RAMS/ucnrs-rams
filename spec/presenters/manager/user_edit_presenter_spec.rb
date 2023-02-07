require "rails_helper"

RSpec.describe Manager::UserEditPresenter do
  describe "delegations" do
    subject { Manager::UserEditPresenter.new(build(:user)) }
    it { is_expected.to delegate_method(:id).to(:form_user).with_prefix(:user) }
    it { is_expected.to delegate_method(:full_name).to(:form_user).with_prefix(:user) }
    it { is_expected.to delegate_method(:institution).to(:form_user).with_prefix(:user) }
    it { is_expected.to delegate_method(:name).to(:user_institution).with_prefix(true) }
  end

  describe "#change_password" do
    it "return password index path" do
      form = RegistrationForm.new(user: create(:user))
      presenter = Manager::UserEditPresenter.new(form)

      output = "<a rel=\"nofollow\" data-method=\"post\" href=\"/password?user_id=#{form.user.id}\">Change Password</a>"

      expect(presenter.change_password).to eq output
    end
  end
end
