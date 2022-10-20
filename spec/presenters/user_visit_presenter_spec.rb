require "rails_helper"

RSpec.describe UserVisitPresenter do
  describe "delegations" do
    subject { UserVisitPresenter.new(create(:user_visit, visit: create(:visit))) }
    it { is_expected.to delegate_method(:full_name).to(:user).with_prefix(true) }
    it { is_expected.to delegate_method(:email).to(:user).with_prefix(true) }
    it { is_expected.to delegate_method(:name).to(:institution).with_prefix(true) }
    it { is_expected.to delegate_missing_methods_to(:user_visit) }
  end

  describe "#requested_date_range" do
    it "generates a date range" do
      arrives_at = Time.current
      departs_at = Time.current + 1.day
      presenter = UserVisitPresenter.new(
        create(:user_visit, arrives_at: arrives_at, departs_at: departs_at)
      )
      allow(DateRangePresenter).to receive(:value)

      presenter.requested_date_range

      expect(DateRangePresenter).to have_received(:value)
        .with(start_date: arrives_at.to_date, end_date: departs_at.to_date)
    end
  end

  describe "#arrives_today?" do
    context "when arrives_at datetime is within 24 hours of today" do
      it "returns true" do
        presenter = UserVisitPresenter.new(
          create(:user_visit, arrives_at: Time.current)
        )

        expect(presenter.arrives_today?).to eq true
      end
    end

    context "when arrives_at datetime is NOT within 24 hours of today" do
      it "returns false" do
        presenter = UserVisitPresenter.new(
          create(:user_visit, arrives_at: 1.day.from_now)
        )

        expect(presenter.arrives_today?).to eq false
      end
    end
  end

  describe "#departs_today?" do
    context "when departs_at datetime is within 24 hours of today" do
      it "returns true" do
        presenter = UserVisitPresenter.new(
          create(:user_visit, departs_at: Time.current)
        )

        expect(presenter.departs_today?).to eq true
      end
    end

    context "when departs_at datetime is NOT within 24 hours of today" do
      it "returns false" do
        presenter = UserVisitPresenter.new(
          create(:user_visit, departs_at: 1.day.from_now)
        )

        expect(presenter.departs_today?).to eq false
      end
    end
  end

  describe "#to_model" do
    it "returns self" do
      presenter = UserVisitPresenter.new(
        create(:user_visit)
      )

      expect(presenter.to_model).to eq presenter
    end
  end

  describe "#to_partial_path" do
    it "returns 'amenity_visit'" do
      presenter = UserVisitPresenter.new(
        create(:user_visit)
      )

      expect(presenter.to_partial_path).to eq 'user_visit'
    end
  end

  describe "#role" do
    it "is the user visit role translated" do
      user_visit = create(:user_visit, role: :docent)
      presenter = UserVisitPresenter.new(user_visit)
      allow(I18n).to receive(:t)
        .with("universal.role.docent")
        .and_return("docent translated")

      role = presenter.role

      expect(role).to eq "docent translated"
    end
  end
end
