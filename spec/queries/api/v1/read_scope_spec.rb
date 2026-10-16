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

    context "when a scoped client has no assigned reserves" do
      let(:api_client) { build(:api_client, platform_wide: false) }

      it "does not treat the client as platform-wide" do
        expect(scope.projects).to be_empty
      end
    end

    context "when the client is scoped to reserves" do
      let(:reserve) { create(:reserve) }
      let(:another_reserve) { create(:reserve) }
      let(:api_client) { create(:api_client, platform_wide: false, reserves: [ reserve, another_reserve ]) }
      let(:reserve_project) { create(:project, reserve: reserve) }

      it "returns projects from assigned reserves and excludes other reserves" do
        another_reserve_project = create(:project, reserve: another_reserve)
        expect(scope.projects).to include(reserve_project, another_reserve_project)
        expect(scope.projects).not_to include(unaffiliated_project)
      end
    end
  end

  describe "#reserves" do
    let(:other_reserve) { create(:reserve) }

    it "returns every reserve to a platform-wide client" do
      expect(scope.reserves).to include(other_reserve)
    end

    context "when the client is scoped to multiple reserves" do
      let(:reserve) { create(:reserve) }
      let(:another_reserve) { create(:reserve) }
      let(:api_client) { create(:api_client, platform_wide: false, reserves: [ reserve, another_reserve ]) }

      it "returns only the client's assigned reserves" do
        expect(scope.reserves).to contain_exactly(reserve, another_reserve)
      end
    end
  end

  describe "#institutions" do
    let(:unaffiliated_institution) { create(:institution) }

    it "returns every institution to a platform-wide client" do
      expect(scope.institutions).to include(unaffiliated_institution)
    end

    context "when the client is scoped to reserves" do
      let(:reserve) { create(:reserve) }
      let(:another_reserve) { create(:reserve) }
      let(:api_client) { create(:api_client, platform_wide: false, reserves: [ reserve, another_reserve ]) }
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

      it "includes participant institutions from every assigned reserve" do
        another_project = create(:project, reserve: another_reserve)

        expect(scope.institutions).to include(another_project.owner.institution)
      end

      it "returns exactly the reserve's managing campus and its projects' participant institutions" do
        membership = create(:project_team_membership, project: project)
        another_reserve.update!(managing_campus: nil)

        expect(scope.institutions).to contain_exactly(
          reserve.managing_campus,
          project.owner.institution,
          project.applicant.institution,
          membership.institution
        )
      end

      it "returns the projects' participant institutions when the reserve has no managing campus" do
        reserve.update!(managing_campus: nil)
        another_reserve.update!(managing_campus: nil)

        expect(scope.institutions)
          .to contain_exactly(project.owner.institution, project.applicant.institution)
      end
    end
  end

  describe "#visits" do
    let(:unaffiliated_visit) { create(:visit) }

    it "returns every visit to a platform-wide client" do
      expect(scope.visits).to include(unaffiliated_visit)
    end

    context "when the client is scoped to reserves" do
      let(:reserve) { create(:reserve) }
      let(:another_reserve) { create(:reserve) }
      let(:api_client) { create(:api_client, platform_wide: false, reserves: [ reserve, another_reserve ]) }
      let(:reserve_visit) { create(:visit, reserve: reserve) }

      it "returns visits from assigned reserves and excludes other reserves" do
        another_reserve_visit = create(:visit, reserve: another_reserve)
        expect(scope.visits).to include(reserve_visit, another_reserve_visit)
        expect(scope.visits).not_to include(unaffiliated_visit)
      end
    end
  end

  describe "#fundings" do
    let(:unaffiliated_funding) { create(:funding) }

    it "returns every funding to a platform-wide client" do
      expect(scope.fundings).to include(unaffiliated_funding)
    end

    context "when the client is scoped to reserves" do
      let(:reserve) { create(:reserve) }
      let(:another_reserve) { create(:reserve) }
      let(:api_client) { create(:api_client, platform_wide: false, reserves: [ reserve, another_reserve ]) }
      let(:project) { create(:project, reserve: reserve) }

      it "returns funding for projects from all assigned reserves" do
        funding = create(:funding, project: project, reserve: nil)
        another_reserve_funding = create(:funding, project: create(:project, reserve: another_reserve), reserve: nil)
        unaffiliated_funding

        expect(scope.fundings).to contain_exactly(funding, another_reserve_funding)
      end

      it "includes a project funding even when its optional reserve differs" do
        funding = create(:funding, project: project, reserve: create(:reserve))

        expect(scope.fundings).to include(funding)
      end

      it "excludes another project's funding even when its optional reserve matches" do
        funding = create(:funding, reserve: reserve)

        expect(scope.fundings).not_to include(funding)
      end
    end
  end
end
