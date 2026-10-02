require "rails_helper"

# The published payload for a visit: which fields are exposed, how each is
# serialized, and how related records are embedded. Serialization is pure, so it
# is exercised without a request or a database. The endpoint's HTTP behaviour is
# covered in spec/requests/api/v1/visits_spec.rb, and the published contract in
# spec/api/v1/visits_spec.rb.
RSpec.describe Api::V1::VisitPresenter do
  describe "#as_json" do
    it "exposes the allowlisted fields and nothing else" do
      visit = build_stubbed(:visit)

      expect(described_class.new(visit).as_json.keys).to match_array(
        %i[
          id type status purpose_of_visit public_use_category study_area
          start_date end_date starts_at ends_at submitted_at project reserve
          submitter visitors created_at updated_at
        ]
      )
    end

    it "serializes the visit's own attributes" do
      visit = build_stubbed(
        :visit,
        status: :approved,
        purpose_of_visit: "Tidepool survey",
        public_use_category: :k_12_class,
        study_area: "North cove",
        start_date: Date.new(2026, 3, 1),
        end_date: Date.new(2026, 3, 5),
        starts_at: Time.new(2026, 3, 1, 9, 0, 0, "-08:00"),
        ends_at: Time.new(2026, 3, 5, 17, 0, 0, "-08:00"),
        submitted_at: Time.new(2026, 2, 1, 12, 0, 0, "-08:00")
      )

      expect(described_class.new(visit).as_json).to include(
        id: visit.id,
        type: "visits",
        status: "approved",
        purpose_of_visit: "Tidepool survey",
        public_use_category: "k_12_class",
        study_area: "North cove",
        start_date: "2026-03-01",
        end_date: "2026-03-05",
        starts_at: "2026-03-01T17:00:00Z",
        ends_at: "2026-03-06T01:00:00Z",
        submitted_at: "2026-02-01T20:00:00Z"
      )
    end

    it "embeds the project, reserve, and submitter as entity stubs" do
      project = build_stubbed(:project, title: "Tidepool Survey", project_type: "Research")
      reserve = build_stubbed(:reserve, name: "Bodega Marine Reserve", short_name: "BMR")
      submitter = build_stubbed(:user, first_name: "Ada", last_name: "Lovelace", orcid: "0000-0002-1825-0097")
      visit = build_stubbed(:visit, project: project, reserve: reserve, user: submitter)

      data = described_class.new(visit).as_json

      expect(data[:project]).to eq(
        type: "projects", id: project.id, title: "Tidepool Survey", project_type: "research"
      )
      expect(data[:reserve]).to eq(
        type: "reserves", id: reserve.id, name: "Bodega Marine Reserve", short_name: "BMR"
      )
      expect(data[:submitter]).to eq(
        type: "users", id: submitter.id, full_name: "Ada Lovelace", orcid: "0000-0002-1825-0097"
      )
    end

    it "embeds each visitor's role, institution, dates, and count" do
      institution = build_stubbed(:institution, name: "University of California, Davis", acronym: "UC Davis")
      visitor = build_stubbed(
        :user_visit,
        role: :faculty,
        count: 3,
        institution: institution,
        arrives_at: Time.new(2026, 3, 1, 9, 0, 0, "-08:00"),
        departs_at: Time.new(2026, 3, 5, 17, 0, 0, "-08:00")
      )
      visit = build_stubbed(:visit, user_visits: [ visitor ])

      visitors = described_class.new(visit).as_json[:visitors]

      expect(visitors.length).to eq(1)
      expect(visitors.first).to eq(
        user: {
          type: "users",
          id: visitor.user.id,
          full_name: visitor.user.full_name,
          orcid: visitor.user.orcid
        },
        role: "faculty",
        institution: {
          type: "institutions",
          id: institution.id,
          name: "University of California, Davis",
          acronym: "UC Davis"
        },
        arrives_at: "2026-03-01T17:00:00Z",
        departs_at: "2026-03-06T01:00:00Z",
        count: 3
      )
    end

    it "orders visitors by id so the payload is deterministic" do
      later = build_stubbed(:user_visit, id: 20)
      earlier = build_stubbed(:user_visit, id: 10)
      visit = build_stubbed(:visit, user_visits: [ later, earlier ])

      ids = described_class.new(visit).as_json[:visitors].map { |visitor| visitor.dig(:user, :id) }

      expect(ids).to eq([ earlier.user.id, later.user.id ])
    end

    it "serializes an absent relation as null" do
      visit = build_stubbed(:visit, project: nil, reserve: nil, user: nil, user_visits: [])

      data = described_class.new(visit).as_json

      expect(data[:project]).to be_nil
      expect(data[:reserve]).to be_nil
      expect(data[:submitter]).to be_nil
      expect(data[:visitors]).to eq([])
    end

    it "serializes timestamps as UTC ISO 8601" do
      visit = build_stubbed(:visit, updated_at: Time.new(2026, 1, 1, 19, 4, 5, "-08:00"))

      expect(described_class.new(visit).as_json[:updated_at]).to eq("2026-01-02T03:04:05Z")
    end
  end
end
