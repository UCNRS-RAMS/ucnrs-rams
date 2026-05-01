require "rails_helper"

RSpec.describe ProjectFundingQuery do
  let(:reserve) { create(:reserve) }
  let(:other_reserve) { create(:reserve) }
  let(:date_begin) { "2026-01-01" }
  let(:date_end) { "2026-01-31" }

  def create_funding_for(visit_attrs: {}, user_visit_attrs: {}, project_attrs: {})
    project = create(:project, { project_type: "Research", status: "Open" }.merge(project_attrs))
    visit = create(:visit, :without_validations, { project: project, reserve: reserve }.merge(visit_attrs))
    create(:user_visit, {
      visit: visit,
      arrives_at: Time.zone.parse("2026-01-10 09:00"),
      departs_at: Time.zone.parse("2026-01-20 17:00"),
      status: :approved,
    }.merge(user_visit_attrs))
    create(:funding, project: project)
  end

  describe "#project_funding" do
    context "when reserve is blank" do
      it "returns no fundings" do
        project_funding_query = Class.new { include ProjectFundingQuery }.new
        create_funding_for

        expect(
          project_funding_query.project_funding(
            reserve: nil, date_begin: date_begin, date_end: date_end,
          ),
        ).to be_empty
        expect(
          project_funding_query.project_funding(
            reserve: "", date_begin: date_begin, date_end: date_end,
          ),
        ).to be_empty
      end

      it "does not hit the database" do
        project_funding_query = Class.new { include ProjectFundingQuery }.new
        expect(Funding).not_to receive(:select)

        project_funding_query.project_funding(
          reserve: nil, date_begin: date_begin, date_end: date_end,
        )
      end
    end

    context "when date_begin or date_end is blank" do
      it "returns no fundings when date_begin is blank" do
        project_funding_query = Class.new { include ProjectFundingQuery }.new
        create_funding_for

        expect(
          project_funding_query.project_funding(
            reserve: reserve.id, date_begin: nil, date_end: date_end,
          ),
        ).to be_empty
      end

      it "returns no fundings when date_end is blank" do
        project_funding_query = Class.new { include ProjectFundingQuery }.new
        create_funding_for

        expect(
          project_funding_query.project_funding(
            reserve: reserve.id, date_begin: date_begin, date_end: nil,
          ),
        ).to be_empty
      end
    end

    context "with a matching funding" do
      it "returns it" do
        project_funding_query = Class.new { include ProjectFundingQuery }.new
        funding = create_funding_for

        result = project_funding_query.project_funding(
          reserve: reserve.id, date_begin: date_begin, date_end: date_end,
        )

        expect(result).to include(funding)
      end
    end

    context "filtering" do
      it "doesnt return fundings whose visit is at a different reserve" do
        project_funding_query = Class.new { include ProjectFundingQuery }.new
        create_funding_for(visit_attrs: { reserve: other_reserve })

        result = project_funding_query.project_funding(
          reserve: reserve.id, date_begin: date_begin, date_end: date_end,
        )

        expect(result).to be_empty
      end

      it "doesnt return fundings whose user_visit ends before date_begin" do
        project_funding_query = Class.new { include ProjectFundingQuery }.new
        create_funding_for(user_visit_attrs: {
          arrives_at: Time.zone.parse("2025-12-01 09:00"),
          departs_at: Time.zone.parse("2025-12-15 17:00"),
        })

        result = project_funding_query.project_funding(
          reserve: reserve.id, date_begin: date_begin, date_end: date_end,
        )

        expect(result).to be_empty
      end

      it "doesnt return fundings whose user_visit starts after date_end" do
        project_funding_query = Class.new { include ProjectFundingQuery }.new
        create_funding_for(user_visit_attrs: {
          arrives_at: Time.zone.parse("2026-02-10 09:00"),
          departs_at: Time.zone.parse("2026-02-20 17:00"),
        })

        result = project_funding_query.project_funding(
          reserve: reserve.id, date_begin: date_begin, date_end: date_end,
        )

        expect(result).to be_empty
      end

      it "doesnt return fundings whose user_visit is not approved" do
        project_funding_query = Class.new { include ProjectFundingQuery }.new
        create_funding_for(user_visit_attrs: { status: :in_review })

        result = project_funding_query.project_funding(
          reserve: reserve.id, date_begin: date_begin, date_end: date_end,
        )

        expect(result).to be_empty
      end

      it "doesnt return fundings on non-research projects" do
        project_funding_query = Class.new { include ProjectFundingQuery }.new
        create_funding_for(project_attrs: { project_type: "Class" })

        result = project_funding_query.project_funding(
          reserve: reserve.id, date_begin: date_begin, date_end: date_end,
        )

        expect(result).to be_empty
      end

      it "doesnt return fundings on incomplete projects" do
        project_funding_query = Class.new { include ProjectFundingQuery }.new
        create_funding_for(project_attrs: { status: "Incomplete" })

        result = project_funding_query.project_funding(
          reserve: reserve.id, date_begin: date_begin, date_end: date_end,
        )

        expect(result).to be_empty
      end
    end
  end
end
