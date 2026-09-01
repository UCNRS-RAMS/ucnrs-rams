# frozen_string_literal: true

require "rails_helper"

RSpec.describe "development database primer" do
  subject(:load_primer) do
    load Rails.root.join("db/seeds/base.rb")
    load Rails.root.join("db/seeds/development.rb")
  end

  it "creates valid representative projects and can run twice without duplicates" do
    load_primer

    research_project = Project.find_by!(title: "Long-term Forest Microclimate Study")
    class_project = Project.find_by!(title: "Field Methods in Oak Woodland Ecology")

    expect(research_project).to be_valid
    expect(research_project.team_memberships.size).to eq(3)
    expect(research_project.visits.size).to eq(1)
    expect(research_project.fundings.size).to eq(1)
    expect(research_project.team_members.where.not(orcid: [nil, ""]).count).to eq(2)
    expect(class_project).to be_valid
    expect(class_project.team_memberships.size).to eq(2)

    visit = research_project.visits.first
    funding = research_project.fundings.first

    expect(visit).to be_approved
    expect(visit.ends_at).to be < Time.current
    expect(visit.user_visits.count).to eq(3)
    expect(visit.user_visits).to all(be_valid)
    expect(research_project.start_date).to be <= visit.start_date
    expect(research_project.end_date).to be >= visit.end_date
    expect(funding.start_date).to be <= visit.start_date
    expect(funding.end_date).to be >= visit.end_date
    expect(funding.grant_number).to eq("EXAMPLE-12345")
    expect(research_project.reserve.doi).to eq("10.0000/example.single-tree")

    manager = User.find_by!(email: "manager@single-tree.test")
    personnel = ReservePersonnel.find_by!(user: manager, reserve: research_project.reserve)

    expect(personnel).to be_valid
    expect(personnel.role).to eq("Administrator")
    expect(manager).to be_manager_of_reserve(research_project.reserve)
    expect(manager.managed_reserves).to contain_exactly(research_project.reserve)

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
