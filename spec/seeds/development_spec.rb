# frozen_string_literal: true

require "rails_helper"

RSpec.describe "development database primer" do
  subject(:load_primer) do
    load Rails.root.join("db/seeds/base.rb")
    load Rails.root.join("db/seeds/development.rb")
  end

  it "creates the development records without validation errors" do
    expect { load_primer }.not_to raise_error
  end

  it "can run twice without duplicating records" do
    load_primer
    counts = primer_counts

    load_primer

    expect(primer_counts).to eq(counts)
  end

  def primer_counts
    [
      Institution.count,
      User.count,
      Reserve.count,
      Amenity.count,
      AmenityRateCategory.count,
      ReservePersonnel.count,
      Project.count,
      ProjectTeamMembership.count,
      Visit.count,
      UserVisit.count,
      Funding.count,
    ]
  end
end
