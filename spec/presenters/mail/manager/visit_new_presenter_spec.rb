require "rails_helper"

RSpec.describe Mail::Manager::VisitNewPresenter do
  describe "delegations" do
    subject { Mail::Manager::VisitNewPresenter.new(build(:visit)) }
    it { is_expected.to delegate_method(:name).to(:visit_reserve).with_prefix(true) }
    it { is_expected.to delegate_method(:short_name).to(:visit_reserve).with_prefix(true) }
    it { is_expected.to delegate_method(:managing_campus).to(:visit_reserve).with_prefix(true) }
  end

  describe "#email_subject" do
    it "presents sentence string for email subject" do
      user = create(:user, first_name: "john", last_name: "doe")
      reserve = create(:reserve, short_name: "small island")
      starts_at = Time.zone.local(2004, 11, 24, 1, 4, 44)
      ends_at = Time.zone.local(2004, 11, 24, 1, 4, 44) + 1.day
      visit = create(:visit, user: user, reserve: reserve, starts_at: starts_at, ends_at: ends_at)
      presenter = Mail::Manager::VisitNewPresenter.new(visit)

      email_subject = presenter.email_subject

      expect(email_subject)
        .to eq "New Visit - small island - Nov. 24, 2004 at 1:04 AM -
          Nov. 25, 2004 at 1:04 AM - john doe".squish
    end
  end

  describe "#visit_reserve_personnel" do
    it "presents visit reserve personnel that receive new visit email only wrapped in PersonnelPresenter" do
      reserve = create(:reserve)
      reserve_personnel1 = create(:reserve_personnel,
        user: create(:user), reserve: reserve, receive_new_visit_email: true
      )
      reserve_personnel2 = create(:reserve_personnel,
        user: create(:user), reserve: reserve, receive_new_visit_email: false
      )
      visit = create(:visit, reserve: reserve)
      presenter = Mail::Manager::VisitNewPresenter.new(visit)

      visit_reserve_personnel = presenter.visit_reserve_personnel

      expect(visit_reserve_personnel).to all(be_a(PersonnelPresenter))
      expect(visit_reserve_personnel.map(&:id)).to match_array [reserve_personnel1.id]
    end
  end

  describe "#visit_reserve_personnel_emails" do
    it "presents sentence string for email subject" do
      reserve = create(:reserve)
      user1 = create(:user, email: "user1@email.com")
      user2 = create(:user, email: "user2@email.com")
      reserve_personnel1 = create(:reserve_personnel,
        user: user1, reserve: reserve, receive_new_visit_email: true,
        email: "i_receive_new_visit@email"
      )
      reserve_personnel2 = create(:reserve_personnel,
        user: user2, reserve: reserve, receive_new_visit_email: false,
        email: "some@email"
      )
      visit = create(:visit, reserve: reserve)
      presenter = Mail::Manager::VisitNewPresenter.new(visit)

      visit_reserve_personnel_emails = presenter.visit_reserve_personnel_emails

      expect(visit_reserve_personnel_emails).to match_array ["user1@email.com"]
    end
  end
end
