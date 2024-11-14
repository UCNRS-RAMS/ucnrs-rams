require "rails_helper"

RSpec.describe "modals/_edit_project_team_membership.html.erb", type: :view do
  it "renders a turbo-frame modal" do
    form = ProjectTeamMembershipForm.new(
      params: create(:project_team_membership, :team_member).attributes
    )
    presenter = Projects::TeamMembershipEditPresenter.new(form: form)

    render partial: "modals/edit_project_team_membership", locals: { presenter: presenter }

    doc = Capybara.string(rendered)
    expect(doc).to have_css("turbo-frame#modal-content")
  end

  it "includes an autocomplete form for institution name" do
    form = ProjectTeamMembershipForm.new(
      params: create(:project_team_membership, :team_member).attributes
    )
    presenter = Projects::TeamMembershipEditPresenter.new(form: form)

    render partial: "modals/edit_project_team_membership", locals: { presenter: presenter }

    doc = Capybara.string(rendered)
    expect(doc).to have_css("div.autocomplete[data-controller='autocomplete'][data-autocomplete-url-value='/institutions']")
    expect(doc).to have_css("div.autocomplete-results-container > .autocomplete-results[data-autocomplete-target='results']")
    expect(doc).to have_css("input[data-autocomplete-target='hidden']", visible: false)
    expect(doc).to have_css("input[data-autocomplete-target='input']")
  end

  it "renders a form with the right fields for a membership" do
    form = ProjectTeamMembershipForm.new(
      params: create(
        :project_team_membership,
        institution: create(:institution, name: "Cool School"),
        user_role: :other,
        active: false,
        is_principal_investigator: true,
        can_edit_project: true,
        can_add_visit: false,
        can_add_project_user: true,
        can_receive_invoice: false
      ).attributes
    )
    presenter = Projects::TeamMembershipEditPresenter.new(form: form)

    render partial: "modals/edit_project_team_membership", locals: { presenter: presenter }

    doc = Capybara.string(rendered)
    expect(doc).to have_css("form[action='/team_memberships/#{form.id}']")
    expect(doc).to have_field("project_team_membership[institution_id]", type: "hidden", with: form.institution_id)
    expect(doc).to have_field("Institution name", with: "Cool School")
    expect(doc).to have_select("User role", with_selected: "Other")
    expect(doc).to have_field("Active", checked: false)
    expect(doc).to have_field("Is principal investigator", checked: true)
    expect(doc).to have_field("Can edit project", checked: true)
    expect(doc).to have_field("Can add visit", checked: false)
    expect(doc).to have_no_field("Change this user to this project's owner")
  end

  it "renders a form with the right fields for a membership in manager view when user is project owner" do
    user = create(:user, :confirmed)
    reserve = create(:reserve)
    create(:reserve_personnel, user: user, reserve: reserve)
    project = create(:project, owner: user, reserve: reserve)

    form = ProjectTeamMembershipForm.new(
      params: create(
        :project_team_membership,
        institution: create(:institution, name: "Cool School"),
        user: user,
        project: project,
        user_role: :other,
        active: false,
        is_principal_investigator: true,
        can_edit_project: true,
        can_add_visit: false,
        can_add_project_user: true,
        can_receive_invoice: false
      ).attributes
    )
    presenter = Manager::Projects::TeamMembershipEditPresenter.new(form: form, reserve: reserve)

    render partial: "modals/edit_project_team_membership", locals: { presenter: presenter }

    doc = Capybara.string(rendered)

    expect(doc).to have_css("form[action='/manager/reserves/#{form.project.reserve_id}/team_memberships/#{form.id}']")
    expect(doc).to have_field("project_team_membership[institution_id]", type: "hidden", with: form.institution_id)
    expect(doc).to have_field("Institution name", with: "Cool School")
    expect(doc).to have_select("User role", with_selected: "Other")
    expect(doc).to have_field("Active", checked: false)
    expect(doc).to have_field("Is principal investigator", checked: true)
    expect(doc).to have_field("Can edit project", checked: true)
    expect(doc).to have_field("Can add visit", checked: false)
    expect(doc).to have_field("Change ownership of the project to this user", checked: true)
  end

  it "renders a form with the right fields for a membership in view when user is not reserve manager" do
    user = create(:user, :confirmed)
    reserve = create(:reserve)
    create(:reserve_personnel, user: user, reserve: reserve)
    project = create(:project, owner: user, reserve: reserve)

    form = ProjectTeamMembershipForm.new(
      params: create(
        :project_team_membership,
        institution: create(:institution, name: "Cool School"),
        user: user,
        project: project,
        user_role: :other,
        active: false,
        is_principal_investigator: true,
        can_edit_project: true,
        can_add_visit: false,
        can_add_project_user: true,
        can_receive_invoice: false
      ).attributes
    )
    presenter = Projects::TeamMembershipEditPresenter.new(form: form)

    render partial: "modals/edit_project_team_membership", locals: { presenter: presenter }

    doc = Capybara.string(rendered)

    expect(doc).to have_css("form[action='/team_memberships/#{form.id}']")
    expect(doc).to have_field("project_team_membership[institution_id]", type: "hidden", with: form.institution_id)
    expect(doc).to have_field("Institution name", with: "Cool School")
    expect(doc).to have_select("User role", with_selected: "Other")
    expect(doc).to have_field("Active", checked: false)
    expect(doc).to have_field("Is principal investigator", checked: true)
    expect(doc).to have_field("Can edit project", checked: true)
    expect(doc).to have_field("Can add visit", checked: false)
    expect(doc).to have_no_field("Change ownership of the project to this user", checked: false)
  end
end
