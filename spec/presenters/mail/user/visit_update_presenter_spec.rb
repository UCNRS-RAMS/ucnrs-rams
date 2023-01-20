require "rails_helper"

RSpec.describe Mail::User::VisitUpdatePresenter do
  describe "delegations" do
    subject { Mail::User::VisitUpdatePresenter.new(build(:visit)) }
    it { is_expected.to delegate_method(:name).to(:visit_reserve).with_prefix(true) }
    it { is_expected.to delegate_method(:short_name).to(:visit_reserve).with_prefix(true) }
    it { is_expected.to delegate_method(:address_line_1).to(:visit_reserve).with_prefix(true) }
    it { is_expected.to delegate_method(:address_line_2).to(:visit_reserve).with_prefix(true) }
    it { is_expected.to delegate_method(:address_line_3).to(:visit_reserve).with_prefix(true) }
    it { is_expected.to delegate_method(:country).to(:visit_reserve).with_prefix(true) }
    it { is_expected.to delegate_method(:phone_number).to(:visit_reserve).with_prefix(true) }
    it { is_expected.to delegate_method(:email_address).to(:visit_reserve).with_prefix(true) }
    it { is_expected.to delegate_method(:email).to(:visit_applicant).with_prefix(true) }
    it { is_expected.to delegate_method(:name).to(:visit_reserve_managing_campus).with_prefix(true) }

    it { is_expected.to delegate_missing_methods_to(:visit) }
  end

  describe "#email_subject" do
    it "presents sentence string for email subject" do
      user = create(:user, first_name: "john", last_name: "doe")
      reserve = create(:reserve, short_name: "small island")
      starts_at = Time.zone.local(2004, 11, 24, 1, 4, 44)
      ends_at = Time.zone.local(2004, 11, 24, 1, 4, 44) + 1.day
      visit = create(:visit, user: user, reserve: reserve, starts_at: starts_at, ends_at: ends_at)
      presenter = Mail::User::VisitUpdatePresenter.new(visit)

      email_subject = presenter.email_subject

      expect(email_subject)
        .to eq "New Visit to the small island - Nov. 24, 2004 at 1:04 AM -
          Nov. 25, 2004 at 1:04 AM - john doe".squish
    end
  end

  describe "#email_bcc_to_list" do
    it "presents list of visit reserve personnel email to bcc" do
      user1 = create(:user)
      user2 = create(:user)
      reserve = create(:reserve)
      create(:reserve_personnel,
        reserve: reserve,
        user: user1,
        email: "john.doe@small_island.com",
        receive_update_email: true,
      )
      create(:reserve_personnel,
        reserve: reserve,
        user: user2,
        email: "jane.doe@small_island.com",
        receive_update_email: true,
      )
      visit = create(:visit, reserve: reserve)
      presenter = Mail::User::VisitUpdatePresenter.new(visit)

      email_bcc_to_list = presenter.email_bcc_to_list

      expect(email_bcc_to_list)
        .to match_array ["john.doe@small_island.com", "jane.doe@small_island.com"]
    end
  end

  describe "#visit_project" do
    it "presents visit project wrapped in Mail::User::ProjectPresenter" do
      project = create(:project)
      visit = create(:visit, project: project)
      presenter = Mail::User::VisitUpdatePresenter.new(visit)

      visit_project = presenter.visit_project

      expect(visit_project).to be_a(Mail::User::ProjectPresenter)
      expect(visit_project.id).to eq project.id
    end
  end
end
