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

  it "gives every reserve a managing campus so reserve reports render" do
    load_primer

    expect(Reserve.where(managing_campus: nil)).to be_empty
  end

  # base.rb seeds deliberately bare placeholder reserves in every environment, so
  # scope the data-quality assertions to the reserves the development primer
  # creates itself.
  it "primes the reserve shapes the API publishes and the ones it normalizes" do
    load Rails.root.join("db/seeds/base.rb")
    placeholders = Reserve.pluck(:id)

    load Rails.root.join("db/seeds/development.rb")
    primed = Reserve.where.not(id: placeholders)

    expect(primed).to be_present

    # Every primed reserve is addressable.
    expect(primed.where(address_line_1: [ nil, "" ])).to be_empty
    expect(primed.where(address_city: [ nil, "" ])).to be_empty
    expect(primed.where(address_postal_code: [ nil, "" ])).to be_empty

    # One carries the identifiers and coordinates the API publishes as values.
    expect(
      primed
        .where.not(doi: [ nil, "", "0" ])
        .where.not(latitude: 0)
        .where.not(longitude: 0),
    ).to be_present

    # One holds the placeholders the API turns into null.
    expect(primed.where(latitude: 0, longitude: 0)).to be_present
    expect(primed.where(year_reserve_established: 0)).to be_present
  end

  it "primes a project with no reserve, which the API serves as a null stub" do
    load_primer

    expect(Project.where(reserve: nil)).to be_present
  end

  it "creates a usable system admin for exercising admin-only pages" do
    load_primer

    admin = User.find_by(email: "admin@rams.test")

    expect(admin).to be_present
    expect(admin).to be_admin
    expect(admin).to be_confirmed
    expect(admin.valid_password?("Password1")).to be(true)
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
