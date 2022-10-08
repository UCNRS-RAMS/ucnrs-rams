require "rails_helper"

RSpec.describe Visits::UserVisitEditPresenter do
  describe "#editing_user_visit" do
    it "return Manager::Visits::UserVisitPresenter" do
      create(:visit)
      form = UserVisitForm.new(params: { id: create(:user_visit).id })
      presenter = Manager::Visits::UserVisitEditPresenter.new(form: form)

      expect(presenter.editing_user_visit).to be_instance_of Manager::Visits::UserVisitPresenter
    end
  end

  describe "#user_days_partial" do
    it "returns path for user_days partial from manager views" do
      user_visit = create(:user_visit, visit: create(:visit))
      form = UserVisitForm.new(params: { id: user_visit.id })
      presenter = Manager::Visits::UserVisitEditPresenter.new(form: form)

      expect(presenter.user_days_partial).to eq "manager/visits/user_visits/user_days"
    end
  end

  describe "#user_visit_form_path" do
    it "returns user_visit_path" do
      visit = create(:visit)
      user_visit = create(:user_visit, visit: visit)
      form = UserVisitForm.new(params: { id: user_visit.id })
      presenter = Manager::Visits::UserVisitEditPresenter.new(form: form)

      expect(presenter.user_visit_form_path).to eq "/manager/reserves/#{visit.reserve_id}/user_visits/#{user_visit.id}"
    end
  end

  describe "#manual_days_same_as_calculated?" do
    let(:user) { create(:user, id: 1) }
    let(:user_visit) { create(:user_visit, visit: create(:visit), user: user) }
    let(:current_date) { Date.current }

    it "returns true if entered actual days are same as auto calculated user days" do
      form_params = {
        id: user_visit.id,
        actual_days: 15,
        count: 5,
        arrives_at: current_date,
        departs_at: current_date + 2.days,
      }
      form = UserVisitForm.new(params: form_params)
      presenter = Manager::Visits::UserVisitEditPresenter.new(form: form)
      expect(presenter.manual_days_same_as_calculated?).to eq true
    end

    it "returns false if entered actual days are different from auto calculated user days" do
      form_params = {
        id: user_visit.id,
        actual_days: 14,
        count: 5,
        arrives_at: current_date,
        departs_at: current_date + 2.days,
      }
      form = UserVisitForm.new(params: form_params)
      presenter = Manager::Visits::UserVisitEditPresenter.new(form: form)

      expect(presenter.manual_days_same_as_calculated?).to eq false
    end
  end

  describe "#user_days_description" do
    let(:user_visit) { create(:user_visit, visit: create(:visit)) }
    let(:current_date) { Date.current }

    it "returns user days description text" do
      form_params = {
        id: user_visit.id,
        actual_days: 14,
        count: 5,
        arrives_at: current_date,
        departs_at: current_date + 2.days,
      }
      form = UserVisitForm.new(params: form_params)
      presenter = Manager::Visits::UserVisitEditPresenter.new(form: form)

      expect(presenter.user_days_description).to eq "3 days x 5 users = 15 userdays"
    end
  end
end
