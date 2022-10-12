require "rails_helper"

RSpec.describe Manager::Visits::VisitNotePresenter do
  let(:user) { create(:user, :confirmed) }
  let(:reserve) { create(:reserve) }
  let(:visit) { create(:visit) }

  describe "#action_name" do
    it "should return the action name for reserve note" do
      note = visit.reserve_notes.create(user: user, reserve_id: reserve.id, action: "test")
      presenter = Manager::Visits::VisitNotePresenter.new(record: note)

      expect(presenter.action_name).to eq("test")
    end
  end

  describe "#date" do
    it "should return the formatted date with time" do
      travel_to Time.zone.local(2004, 11, 24, 1, 4, 44)
      note = visit.reserve_notes.create(user: user, reserve_id: reserve.id, created_at: Time.current)
      presenter = Manager::Visits::VisitNotePresenter.new(record: note)

      expect(presenter.date).to eq("Nov. 24, 2004 at  1:04 AM")
    end
  end

  describe "#message" do
    it "should return the note message" do
      note = visit.reserve_notes.create(user: user, reserve_id: reserve.id, note: "test note details")
      presenter = Manager::Visits::VisitNotePresenter.new(record: note)

      expect(presenter.message).to eq("test note details")
    end 
  end

  describe "#user_name" do
    it "should return the logs array for project and its visits" do
      note = visit.reserve_notes.new(user: user, reserve_id: reserve.id)

      presenter = Manager::Visits::VisitNotePresenter.new(record: note)

      expect(presenter.user_name).to eq(user.full_name)
    end
  end
end
