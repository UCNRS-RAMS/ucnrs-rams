require "rails_helper"

RSpec.describe Manager::Visits::ActivityAndNotesIndexPresenter do
  let(:user) { create(:user, :confirmed) }
  let(:reserve) { create(:reserve) }
  let(:visit) { create(:visit) }
  let(:presenter) { Manager::Visits::ActivityAndNotesIndexPresenter.new(visit: visit) }

  describe "#logs_scope" do
    it "should return the logs array for visit and its visits" do
      log1 = visit.logs.create(user: user, reserve_id: reserve.id)
      log2 = visit.logs.create(user: user, reserve_id: reserve.id)

      expect(presenter.logs_scope).to eq([log1, log2])
    end
  end

  describe "#notes_scope" do
    it "should return the reserve_notes for visit and its visits" do
      note1 = visit.reserve_notes.create(user: user, reserve_id: reserve.id)
      note2 = visit.reserve_notes.create(user: user, reserve_id: reserve.id)

      expect(presenter.notes_scope).to eq([note1, note2])
    end
  end

  describe "#logs" do
    it "should return an array of activity_presenters" do
      log1 = visit.logs.create(user: user, reserve_id: reserve.id)
      log2 = visit.logs.create(user: user, reserve_id: reserve.id)

      expect(presenter.logs.map(&:id)).to eq([log1.id, log2.id])
    end
  end

  describe "#notes" do
    it "should return the reserve_notes for visit and its visits" do
      note1 = visit.reserve_notes.create(user: user, reserve_id: reserve.id)
      note2 = visit.reserve_notes.create(user: user, reserve_id: reserve.id)

      expect(presenter.notes.map(&:id)).to eq([note1.id, note2.id])
    end
  end
end
