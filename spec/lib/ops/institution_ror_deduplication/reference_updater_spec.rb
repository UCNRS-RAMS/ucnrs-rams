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
    updater = described_class.new(connection)

    first_move = updater.move(duplicate.id, retained.id)

    expect(first_move).to include("users" => 2, "institutions" => 1)
    expect(updater.totals).to include("users" => 2, "institutions" => 1)
    expect(first_user.reload.institution_id).to eq(retained.id)
    expect(second_user.reload.institution_id).to eq(retained.id)
    expect(managed_institution.reload.managing_institution_id).to eq(retained.id)

    expect(updater.move(duplicate.id, retained.id)).to eq({})
    expect(updater.totals).to include("users" => 2, "institutions" => 1)
  end
end
