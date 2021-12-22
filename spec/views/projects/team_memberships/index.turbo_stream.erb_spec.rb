require "rails_helper"

RSpec.describe "projects/team_memberships/index.turbo_stream.erb", type: :view do
  it "renders an empty modal" do
    assign(:presenter, Projects::TeamMembershipsIndexPresenter.new(
      current_step: 2,
      project: build_stubbed(:project),
    ))

    render template: "projects/team_memberships/index", formats: [:turbo_stream]

    expect(rendered).to include(
      '<turbo-stream action="replace" target="modal-content"'
    )
    expect(rendered).to include(
      '<turbo-frame id="modal-content" class="modal-content empty"'
    )
  end

  it "renders the table of team members" do
    assign(:presenter, Projects::TeamMembershipsIndexPresenter.new(
      current_step: 2,
      project: build_stubbed(:project),
    ))

    render template: "projects/team_memberships/index", formats: [:turbo_stream]

    expect(rendered).to include(
      '<turbo-stream action="replace" target="team-member-table"'
    )
    expect(rendered).to include(
      '<turbo-frame id="team-member-table'
    )
  end
end
