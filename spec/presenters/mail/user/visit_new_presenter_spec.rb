require "rails_helper"

RSpec.describe Mail::User::VisitNewPresenter do
  describe "delegations" do
    subject { Mail::User::VisitNewPresenter.new(build(:visit)) }
    it { is_expected.to delegate_method(:name).to(:visit_reserve).with_prefix(true) }
    it { is_expected.to delegate_method(:short_name).to(:visit_reserve).with_prefix(true) }
    it { is_expected.to delegate_method(:managing_campus).to(:visit_reserve).with_prefix(true) }
    it { is_expected.to delegate_method(:address_line_1).to(:visit_reserve).with_prefix(true) }
    it { is_expected.to delegate_method(:address_line_2).to(:visit_reserve).with_prefix(true) }
    it { is_expected.to delegate_method(:address_line_3).to(:visit_reserve).with_prefix(true) }
    it { is_expected.to delegate_method(:managing_campus).to(:visit_reserve).with_prefix(true) }
    it { is_expected.to delegate_method(:country).to(:visit_reserve).with_prefix(true) }
    it { is_expected.to delegate_method(:phone_number).to(:visit_reserve).with_prefix(true) }
    it { is_expected.to delegate_method(:email_address).to(:visit_reserve).with_prefix(true) }
    it { is_expected.to delegate_method(:personnel).to(:visit_reserve).with_prefix(true) }
  end

  describe "#email_subject" do
    it "presents sentence string for email subject" do
      user = create(:user, first_name: "john", last_name: "doe")
      reserve = create(:reserve, short_name: "small island")
      starts_at = Time.zone.local(2004, 11, 24, 1, 4, 44)
      ends_at = Time.zone.local(2004, 11, 24, 1, 4, 44) + 1.day
      visit = create(:visit, user: user, reserve: reserve, starts_at: starts_at, ends_at: ends_at)
      presenter = Mail::User::VisitNewPresenter.new(visit)

      email_subject = presenter.email_subject

      expect(email_subject)
        .to eq "New Visit to the small island - Nov. 24, 2004 at 1:04 AM -
          Nov. 25, 2004 at 1:04 AM - john doe".squish
    end
  end

  describe "#visit_reserve_managing_campus_name" do
    it "presents the visit applicant email" do
      institution = create(:institution, name: "university1")
      reserve = create(:reserve, managing_campus: institution)
      visit = create(:visit, reserve: reserve)
      presenter = Mail::User::VisitNewPresenter.new(visit)

      visit_reserve_managing_campus_name = presenter.visit_reserve_managing_campus_name

      expect(visit_reserve_managing_campus_name).to eq "university1"
    end
  end
end
