# frozen_string_literal: true

require "rails_helper"

RSpec.describe Ops::InstitutionRorDeduplication::ReferenceUpdater do
  let(:connection) { ActiveRecord::Base.connection }

  it "repoints references and accumulates updated row totals by table" do
    retained = create(:institution)
    duplicate = create(:institution)
    first_user = create(:user, institution: duplicate)
    second_user = create(:user, institution: duplicate)
    managed_institution = create(:institution, managing_institution_id: duplicate.id)
    reserve = create(:reserve, managing_campus: duplicate)
    updater = described_class.new(connection)

    first_move = updater.move(duplicate.id, retained.id)

    expect(first_move).to include("users" => 2, "institutions" => 1, "reserves" => 1)
    expect(updater.totals).to include("users" => 2, "institutions" => 1, "reserves" => 1)
    expect(first_user.reload.institution_id).to eq(retained.id)
    expect(second_user.reload.institution_id).to eq(retained.id)
    expect(managed_institution.reload.managing_institution_id).to eq(retained.id)
    expect(reserve.reload.managing_campus_id).to eq(retained.id)

    expect(updater.move(duplicate.id, retained.id)).to eq({})
    expect(updater.totals).to include("users" => 2, "institutions" => 1, "reserves" => 1)
  end

  describe "#remaining_references" do
    it "returns an empty array when no references exist" do
      institution = create(:institution)
      updater = described_class.new(connection)

      expect(updater.remaining_references(institution.id)).to eq([])
    end

    it "returns table and column descriptors when references exist" do
      institution = create(:institution)
      create(:user, institution: institution)
      create(:reserve, managing_campus: institution)
      updater = described_class.new(connection)

      expect(updater.remaining_references(institution.id)).to contain_exactly(
        "users.institution_id (1)",
        "reserves.managing_campus_id (1)"
      )
    end
  end
end
