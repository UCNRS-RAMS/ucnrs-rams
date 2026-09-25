require "rails_helper"

# The v1 read policy: which records an ApiClient is allowed to see, by resource.
RSpec.describe Api::V1::ReadScope do
  subject(:scope) { described_class.new(api_client) }

  let(:api_client) { create(:api_client) }

  describe "#projects" do
    let(:unaffiliated_project) { create(:project) }

    it "returns every project to a platform-wide client" do
      expect(scope.projects).to include(unaffiliated_project)
    end

    context "when the client is scoped to a reserve" do
      let(:reserve) { create(:reserve) }
      let(:api_client) { create(:api_client, reserve: reserve) }
      let(:reserve_project) { create(:project, reserve: reserve) }

      it "returns only the reserve's projects" do
        expect(scope.projects).to include(reserve_project)
        expect(scope.projects).not_to include(unaffiliated_project)
      end
    end
  end

  describe "#institutions" do
    let(:unaffiliated_institution) { create(:institution) }

    it "returns every institution to a platform-wide client" do
      expect(scope.institutions).to include(unaffiliated_institution)
    end

    context "when the client is scoped to a reserve" do
      let(:reserve) { create(:reserve) }
      let(:api_client) { create(:api_client, reserve: reserve) }
      let(:project) { create(:project, reserve: reserve) }

      it "includes the reserve's managing campus" do
        expect(scope.institutions).to include(reserve.managing_campus)
      end

      it "includes the institutions of the project's owner and applicant" do
        expect(scope.institutions)
          .to include(project.owner.institution, project.applicant.institution)
      end

      it "includes the institutions of the project's team members" do
        membership = create(:project_team_membership, project: project)

        expect(scope.institutions).to include(membership.institution)
      end

      it "excludes institutions unaffiliated with the reserve" do
        expect(scope.institutions).not_to include(unaffiliated_institution)
      end

      it "excludes the institutions of another reserve's projects" do
        expect(scope.institutions).not_to include(create(:project).owner.institution)
      end

      it "returns exactly the reserve's managing campus and its projects' participant institutions" do
        membership = create(:project_team_membership, project: project)

        expect(scope.institutions).to contain_exactly(
          reserve.managing_campus,
          project.owner.institution,
          project.applicant.institution,
          membership.institution
        )
      end

      it "returns the projects' participant institutions when the reserve has no managing campus" do
        reserve.update!(managing_campus: nil)

        expect(scope.institutions)
          .to contain_exactly(project.owner.institution, project.applicant.institution)
      end
    end
  end
end
