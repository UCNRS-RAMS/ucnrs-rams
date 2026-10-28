require "rails_helper"

# The published payload for a project team membership: which fields are
# exposed, how each is serialized, and how related records are embedded.
# Serialization is pure, so it is exercised without a request or a database.
# The endpoint's HTTP behaviour is covered in
# spec/requests/api/v1/team_memberships_spec.rb, and the published contract in
# spec/api/v1/team_memberships_spec.rb.
RSpec.describe Api::V1::TeamMembershipPresenter do
  describe "#as_json" do
    it "exposes the allowlisted fields and nothing else" do
      membership = build_stubbed(:project_team_membership)

      expect(described_class.new(membership).as_json.keys).to match_array(
        %i[
          id type active user_role is_principal_investigator project user
          institution created_at updated_at
        ]
      )
    end

    it "serializes the membership's own attributes" do
      membership = build_stubbed(
        :project_team_membership,
        active: false,
        user_role: :faculty,
        is_principal_investigator: true
      )

      expect(described_class.new(membership).as_json).to include(
        id: membership.id,
        type: "team_memberships",
        active: false,
        user_role: "faculty",
        is_principal_investigator: true
      )
    end

    it "embeds the project, user, and institution as entity stubs" do
      project = build_stubbed(:project, title: "Tidepool Survey", project_type: "Research")
      user = build_stubbed(:user, first_name: "Ada", last_name: "Lovelace", orcid: "0000-0002-1825-0097")
      institution = build_stubbed(
        :institution,
        name: "University of California, Davis",
        acronym: "UC Davis"
      )
      membership = build_stubbed(
        :project_team_membership,
        project: project,
        user: user,
        institution: institution
      )

      data = described_class.new(membership).as_json

      expect(data[:project]).to eq(
        type: "projects", id: project.id, title: "Tidepool Survey", project_type: "research"
      )
      expect(data[:user]).to eq(
        type: "users", id: user.id, full_name: "Ada Lovelace", orcid: "0000-0002-1825-0097"
      )
      expect(data[:institution]).to eq(
        type: "institutions", id: institution.id, name: "University of California, Davis", acronym: "UC Davis"
      )
    end

    it "serializes an absent institution as null" do
      membership = build_stubbed(:project_team_membership, institution: nil)

      expect(described_class.new(membership).as_json[:institution]).to be_nil
    end

    it "serializes timestamps as UTC ISO 8601" do
      membership = build_stubbed(
        :project_team_membership,
        updated_at: Time.new(2026, 1, 1, 19, 4, 5, "-08:00")
      )

      expect(described_class.new(membership).as_json[:updated_at]).to eq("2026-01-02T03:04:05Z")
    end
  end
end
