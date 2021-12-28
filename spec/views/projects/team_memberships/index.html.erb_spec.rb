require "rails_helper"

RSpec.describe "index.html.erb" do
  describe "on any render" do
    it "includes steps (on step 2)" do
      project = create(:project)
      assign(:presenter, Projects::TeamMembershipsIndexPresenter.new(
        current_step: 2,
        project: project,
      ))
      
      controller.request.path_parameters[:project_id] = project.id
      render template: "projects/team_memberships/index"

      doc = Capybara.string(rendered)
      expect(doc).to have_css("section.progress-steps")
      expect(doc).to have_css(".progress-steps li.active:nth-child(2)")
    end

    it "displays a form to add a project team member" do
      project = create(:project)
      assign(:presenter, Projects::TeamMembershipsIndexPresenter.new(
        current_step: 2,
        project: project,
      ))

      controller.request.path_parameters[:project_id] = project.id
      render template: "projects/team_memberships/index"

      doc = Capybara.string(rendered)
      expect(doc).to have_css("form[action='/projects/#{project.id}/team_memberships']")
      expect(doc).to have_field("project_team_membership_full_name", type: "text")
      expect(doc).to have_field("project_team_membership_user_id", type: "hidden")
      expect(doc).to have_field("Project Role", type: "select")
    end

    it "includes markup for autocomplete on the user field" do
      project = create(:project)
      assign(:presenter, Projects::TeamMembershipsIndexPresenter.new(
        current_step: 2,
        project: project,
      ))

      controller.request.path_parameters[:project_id] = project.id
      render template: "projects/team_memberships/index"

      doc = Capybara.string(rendered)
      field = doc.find(".field.autocomplete[data-controller='autocomplete']")
      expect(field["data-autocomplete-url-value"]).to eq "/users"
      expect(field).to have_css("input[data-autocomplete-target='input']")
      expect(field).to have_css(".autocomplete-results-container .autocomplete-results[data-autocomplete-target='results']")
    end
  end

  it "displays errors that are on the form object" do
    membership = create(:project_team_membership)
    form = ProjectTeamMembershipForm.new(
      project: membership.project,
      params: membership.attributes,
    )
    assign(:presenter, Projects::TeamMembershipsIndexPresenter.new(
      current_step: 2,
      project: membership.project,
      form: form
    ))
    form.validate

    controller.request.path_parameters[:project_id] = membership.project.id
    render template: "projects/team_memberships/index"

    doc = Capybara.string(rendered)
    expect(doc).to display_error("already on this team").for_field("Full Name")
    expect(doc).to display_error("must select an option").for_field("Project Role")
  end

  describe "the submit button" do
    it "renders a button with the correct text for step 2" do
      membership = create(:project_team_membership)
      form = ProjectTeamMembershipForm.new(
        project: membership.project,
        params: membership.attributes,
      )
      assign(:presenter, Projects::TeamMembershipsIndexPresenter.new(
        current_step: 2,
        project: membership.project,
        form: form
      ))

      controller.request.path_parameters[:project_id] = membership.project.id
      render template: "projects/team_memberships/index"

      doc = Capybara.string(rendered)
      expect(doc).to have_css("form[method='get'][action='/projects/#{membership.project.id}/permits']", text: "Next: Permits")
    end
  end
end
