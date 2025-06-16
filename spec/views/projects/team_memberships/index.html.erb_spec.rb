require "rails_helper"

RSpec.describe "index.html.erb" do
  describe "on any render" do
    it "includes steps (on step 2)" do
      project = create(:project)
      assign(:presenter, Projects::TeamMembershipsIndexPresenter.new(
        current_step: 2,
        project: project,
      ))

      render template: "projects/team_memberships/index"

      doc = Capybara.string(rendered)
      expect(doc).to have_css("section.progress-steps")
      expect(doc).to have_css(".progress-steps li.active:nth-child(2)")
    end

    it "displays a form to add a project team member" do
      membership = create(:project_team_membership, :principal_investigator)
      project = membership.project
      assign(:presenter, Projects::TeamMembershipsIndexPresenter.new(
        current_step: 2,
        project: membership.project,
        current_user: membership.user,
      ))

      render template: "projects/team_memberships/index"

      doc = Capybara.string(rendered)
      expect(doc).to have_css("form[action='/projects/#{project.id}/team_memberships']")
      expect(doc).to have_field("project_team_membership_full_name", type: "text")
      expect(doc).to have_field("project_team_membership_user_id", type: "hidden")
      expect(doc).to have_field("Project Role", type: "select")
    end

    it "includes markup for autocomplete on the user field" do
      membership = create(:project_team_membership, :principal_investigator)
      project = membership.project
      assign(:presenter, Projects::TeamMembershipsIndexPresenter.new(
        current_step: 2,
        project: project,
        current_user: membership.user,
      ))

      render template: "projects/team_memberships/index"

      doc = Capybara.string(rendered)
      field = doc.find(".field.autocomplete[data-controller='autocomplete']")
      expect(field["data-autocomplete-url-value"]).to eq "/users"
      expect(field).to have_css("input[data-autocomplete-target='input']")
      expect(field).to have_css(".autocomplete-results-container .autocomplete-results[data-autocomplete-target='results']")
    end
  end

  it "displays errors that are on the form object" do
    membership = create(:project_team_membership, :principal_investigator)
    form = ProjectTeamMembershipForm.new(
      project: membership.project,
      params: membership.attributes,
    )
    assign(:presenter, Projects::TeamMembershipsIndexPresenter.new(
      current_step: 2,
      project: membership.project,
      form: form,
      current_user: membership.user,
    ))
    form.validate

    render template: "projects/team_memberships/index"

    doc = Capybara.string(rendered)
    expect(doc).to display_error("already on this team").for_field("Full Name")
    expect(doc).to display_error(I18n.t("activerecord.errors.models.project_team_membership_form.attributes.project_role.inclusion")).for_field("Project Role")
  end

  describe "if the user does not have can_edit_project permission" do
    it "does not show the add user form" do
      membership = create(:project_team_membership, active: true, can_edit_project: false)
      project = membership.project
      assign(:presenter, Projects::TeamMembershipsIndexPresenter.new(
        current_step: 2,
        project: membership.project,
        current_user: membership.user,
      ))

      render template: "projects/team_memberships/index"

      doc = Capybara.string(rendered)
      expect(doc).to have_no_css("form[action='/projects/#{project.id}/team_memberships']")
    end
  end

  describe "the submit button" do
    it "renders a button with the correct text for step 2" do
      membership = create(:project_team_membership, :principal_investigator)
      form = ProjectTeamMembershipForm.new(
        project: membership.project,
        params: membership.attributes,
      )
      assign(:presenter, Projects::TeamMembershipsIndexPresenter.new(
        current_step: 2,
        project: membership.project,
        form: form,
        current_user: membership.user,
      ))

      controller.request.path_parameters[:project_id] = membership.project.id
      render template: "projects/team_memberships/index"

      doc = Capybara.string(rendered)
      expect(doc).to have_css("form[method='get'][action='/projects/#{membership.project.id}/questions']", text: "Next: Permits")
    end
  end

  describe "navigating to the previous page" do
    it "renders a link to go back to the previous step (edit project)" do
      project = build_stubbed(:project)
      assign(:presenter, Projects::TeamMembershipsIndexPresenter.new(
        current_step: 2,
        project: project,
      ))

      render template: "projects/team_memberships/index"

      doc = Capybara.string(rendered)
      expect(doc).to have_css(".controls a[href='/projects/#{project.id}/edit']", text: "Go Back")
    end
  end
end
