require "rails_helper"

RSpec.describe Mail::User::ProjectContactManagerPresenter do
  describe "delegations" do
    subject { Mail::User::ProjectContactManagerPresenter.new(
        project: :project,
        reserve: :reserve,
        user: :user,
      )
    }
    it { is_expected.to delegate_method(:id).to(:project).with_prefix(true) }
    it { is_expected.to delegate_method(:id).to(:reserve).with_prefix(true) }
    it { is_expected.to delegate_method(:name).to(:reserve).with_prefix(true) }
    it { is_expected.to delegate_method(:full_name).to(:user).with_prefix(true) }
    it { is_expected.to delegate_method(:email).to(:user).with_prefix(true) }
  end

  describe "#email_to" do
    it "presents the emails of reserve personnel who opted in to contact requests" do
      reserve = create(:reserve, email_address: "the_reserve@ucnature.org")
      opted_in = create(:user, email: "opted.in@ucnature.org")
      create(:reserve_personnel, reserve: reserve, user: opted_in, receive_project_interest_email: true)
      create(:reserve_personnel, reserve: reserve, receive_project_interest_email: false)
      create(:reserve_personnel, receive_project_interest_email: true)
      presenter = Mail::User::ProjectContactManagerPresenter.new(
        project: :project,
        reserve: reserve,
        user: :user,
      )

      email_to = presenter.email_to

      expect(email_to).to eq [ "opted.in@ucnature.org" ]
    end
  end

  describe "#email_subject" do
    it "presents sentence string for email subject" do
      reserve = create(:reserve, name: "Reserve 123")
      project = create(:project)
      presenter = Mail::User::ProjectContactManagerPresenter.new(
        project: project,
        reserve: reserve,
        user: :user,
      )

      email_subject = presenter.email_subject

      expect(email_subject).to eq "Project #{project.id} discussion for [Reserve 123]".squish
    end
  end
end
