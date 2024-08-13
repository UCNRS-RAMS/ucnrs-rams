require "rails_helper"

RSpec.describe "projects/team_memberships/edit.turbo_stream.erb", type: :view do
  it "renders an empty modal" do
    project_team_membership = create(:project_team_membership)
    form = ProjectTeamMembershipForm.new(params: { id: project_team_membership.id })
    @presenter = Projects::TeamMembershipEditPresenter.new(form:)

    render template: "projects/team_memberships/edit", formats: [:turbo_stream]

    expect(rendered).to include(
      '<turbo-stream action="update" target="modal-content"',
    )
    expect(rendered).to include('<turbo-frame id="modal-content"')
  end
end
