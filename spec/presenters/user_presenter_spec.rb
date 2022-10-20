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

    it "presents the autocomplete description without extra hyphens if there is no email" do
      presenter = UserPresenter.new(
        build(
          :user,
          first_name: "First",
          last_name: "Last",
          email: nil,
          institution: build(:institution, name: "Foo University")
        )
      )

      expect(presenter.autocomplete_description).to eq "First Last - Foo University"
    end
  end

  describe "#masked_email" do
    it "obfuscates the user portion of the email address if the user has an email" do
      user = build(:user, email: "one-two-three@numbers.test")
      presenter = UserPresenter.new(user)

      expect(presenter.masked_email).to eq "oxxxxxxxxxxxe@numbers.test"
    end

    it "is nil if the user does not have an email" do
      user = build(:user, email: nil)
      presenter = UserPresenter.new(user)

      expect(presenter.masked_email).to be_nil
    end
  end

  describe "delegation" do
    subject { UserPresenter.new(build(:user)) }
    it { is_expected.to delegate_missing_methods_to(:user) }
  end

  describe "#role" do
    it "is the user role translated" do
      user = create(:user, role: :docent)
      presenter = UserPresenter.new(user)
      allow(I18n).to receive(:t)
        .with("universal.role.docent")
        .and_return("docent translated")

      role = presenter.role

      expect(role).to eq "docent translated"
    end
  end
end
