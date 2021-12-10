require "rails_helper"

RSpec.describe UserPresenter, type: :presenter do
  describe "autocomplete_description" do
    it "presents the full_name, institution name, and masked email" do
      presenter = UserPresenter.new(
        build(
          :user,
          first_name: "First",
          last_name: "Last",
          email: "john@doe.test",
          institution: build(:institution, name: "Foo University")
        )
      )

      expect(presenter.autocomplete_description).to eq "First Last - Foo University - jxxn@doe.test"
    end
  end

  describe "#masked_email" do
    it "obfuscates the user portion of the email address" do
      user = build(:user, email: "one-two-three@numbers.test")
      presenter = UserPresenter.new(user)

      expect(presenter.masked_email).to eq "oxxxxxxxxxxxe@numbers.test"
    end
  end

  describe "delegation" do
    subject { UserPresenter.new(build(:user)) }
    it { is_expected.to delegate_missing_methods_to(:user) }
  end
end
