require "rails_helper"

RSpec.describe "projects/team_memberships/edit.html.erb", type: :view do
  it "renders a turbo-frame modal" do
    form = ProjectTeamMembershipForm.new(
      params: create(:project_team_membership, :team_member).attributes
    )
    assign(:presenter, Projects::TeamMembershipEditPresenter.new(form: form))

    render template: "projects/team_memberships/edit"

    doc = Capybara.string(rendered)
    expect(doc).to have_css("turbo-frame#modal-content")
  end

  it "has a link to destroy a team membership" do
    form = ProjectTeamMembershipForm.new(
      params: create(:project_team_membership, :team_member).attributes
    )
    assign(:presenter, Projects::TeamMembershipEditPresenter.new(form: form))

    render template: "projects/team_memberships/edit"

    doc = Capybara.string(rendered)
    expect(doc).to have_css("a[data-method='delete']")
  end
end
