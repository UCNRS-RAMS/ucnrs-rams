require "rails_helper"

RSpec.describe "shared/projects/team_memberships/_form.html.erb", type: :view do
  it "displays a form to add a project team member" do
    membership = create(:project_team_membership, :principal_investigator)
    project = membership.project
    presenter = Projects::TeamMembershipsIndexPresenter.new(
      current_step: 2,
      project: membership.project,
      current_user: membership.user,
    )

    render partial: "shared/projects/team_memberships/form", locals: { presenter: presenter }

    doc = Capybara.string(rendered)
    expect(doc).to have_css("form[action='/projects/#{project.id}/team_memberships']")
    expect(doc).to have_field("project_team_membership_full_name", type: "text")
    expect(doc).to have_field("project_team_membership_user_id", type: "hidden")
    expect(doc).to have_field("Project Role", type: "select")
  end

  it "includes markup for autocomplete on the user field" do
    membership = create(:project_team_membership, :principal_investigator)
    project = membership.project
    presenter = Projects::TeamMembershipsIndexPresenter.new(
      current_step: 2,
      project: project,
      current_user: membership.user,
    )

    render partial: "shared/projects/team_memberships/form", locals: { presenter: presenter }

    doc = Capybara.string(rendered)
    field = doc.find(".field.autocomplete[data-controller='autocomplete']")
    expect(field["data-autocomplete-url-value"]).to eq "/users"
    expect(field).to have_css("input[data-autocomplete-target='input']")
    expect(field).to have_css(".autocomplete-results-container .autocomplete-results[data-autocomplete-target='results']")
  end

  it "displays errors that are on the form object" do
    membership = create(:project_team_membership, :principal_investigator)
    form = ProjectTeamMembershipForm.new(
      project: membership.project,
      params: membership.attributes,
    )
    presenter = Projects::TeamMembershipsIndexPresenter.new(
      current_step: 2,
      project: membership.project,
      form: form,
      current_user: membership.user,
    )
    form.validate

    render partial: "shared/projects/team_memberships/form", locals: { presenter: presenter }

    doc = Capybara.string(rendered)
    expect(doc).to display_error("already on this team").for_field("Full Name")
    expect(doc).to display_error(I18n.t("activerecord.errors.models.project_team_membership_form.attributes.project_role.inclusion")).for_field("Project Role")
  end
end
