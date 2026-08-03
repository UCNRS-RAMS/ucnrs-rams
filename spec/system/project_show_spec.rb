require "rails_helper"

RSpec.describe "Project show page", type: :system, js: true do
  it "shows a complete summary of an open research project" do
    travel_to Time.zone.local(2024, 5, 20, 9, 0) do
      institution = create(:institution, name: "UC Berkeley")
      user = create(:user, :confirmed, first_name: "Taricha", last_name: "torosa", institution: institution)
      reserve = create(:reserve, name: "Angelo Coast Range Reserve")
      other_reserve = create(:reserve, name: "Sagehen Creek Field Station")
      project = create(
        :project,
        reserve: reserve,
        applicant: user,
        owner: user,
        status: :open,
        project_type: :research,
        title: "Counting Newts",
        thesis_title: "Newts of the North Coast",
        abstract: "A study of newt migration.",
        discipline: "Ecology",
        start_date: Date.new(2024, 6, 1),
        end_date: Date.new(2024, 8, 31),
        submitted_at: Time.zone.local(2024, 5, 15, 14, 30),
        involves_mammals: true,
        involves_birds: true,
        involves_none: false,
        method_description: "Counting newts by hand.",
        method_study_area: "The creek bed.",
        method_remove_organisms: true,
        method_soil_disturbance: false,
        method_chemicals: true,
        method_chemicals_list: "Sodium chloride",
      )
      create(
        :project_team_membership,
        :principal_investigator,
        project: project,
        user: user,
        institution: institution,
        active: true,
      )
      create(
        :project_team_membership,
        :team_member,
        project: project,
        user: create(:user, :confirmed, first_name: "Taricha", last_name: "sierrae"),
        institution: create(:institution, name: "Newt University"),
        active: true,
      )
      create(
        :project_team_membership,
        :team_member,
        project: project,
        user: create(:user, :confirmed, first_name: "Removed", last_name: "Member"),
        active: false,
      )
      create(
        :funding,
        project: project,
        title: "Newt Migration Grant",
        sponsor: :national_science_foundation,
        award_amount: 25_000,
      )
      federal_permit = create(
        :permit,
        authority: "Federal",
        statement: "Holds a federal collecting permit",
      )
      state_permit = create(
        :permit,
        authority: "State",
        statement: "Holds a state scientific collecting permit",
      )
      unanswered_permit = create(:permit, authority: "Local", statement: "Holds a local permit")
      create(:project_permit_answer, project: project, permit: federal_permit, answer: true)
      create(:project_permit_answer, project: project, permit: state_permit, answer: true)
      create(:project_permit_answer, project: project, permit: unanswered_permit, answer: false)
      boolean_question = create(
        :reserve_question,
        :boolean_question,
        reserve: reserve,
        question: "Will you use a drone?",
        statement: "Plans to fly a drone",
      )
      text_question = create(
        :reserve_question,
        :text_question,
        reserve: other_reserve,
        question: "Which trails will you use?",
      )
      declined_question = create(
        :reserve_question,
        :boolean_question,
        reserve: reserve,
        question: "Will you camp overnight?",
        statement: "Plans to camp overnight",
      )
      create(
        :project_reserve_answer,
        project: project,
        reserve_question: boolean_question,
        boolean_answer: true,
      )
      create(
        :project_reserve_answer,
        project: project,
        reserve_question: text_question,
        text_answer: "The east ridge trail",
      )
      create(
        :project_reserve_answer,
        project: project,
        reserve_question: declined_question,
        boolean_answer: false,
      )
      visit_record = create(
        :visit,
        project: project,
        reserve: reserve,
        user: user,
        status: :approved,
        starts_at: Time.zone.local(2024, 6, 10, 9, 0),
        ends_at: Time.zone.local(2024, 6, 14, 17, 0),
        start_date: Date.new(2024, 6, 10),
        end_date: Date.new(2024, 6, 14),
      )
      create(
        :user_visit,
        visit: visit_record,
        user: user,
        institution: institution,
        count: 1,
        arrives_at: Time.zone.local(2024, 6, 10, 9, 0),
        departs_at: Time.zone.local(2024, 6, 14, 17, 0),
      )
      2.times do
        create(
          :amenity_visit,
          visit: visit_record,
          arrives_on: Date.new(2024, 6, 10),
          departs_on: Date.new(2024, 6, 14),
          arrives_at: Time.zone.local(2024, 6, 10, 9, 0),
          departs_at: Time.zone.local(2024, 6, 14, 17, 0),
          arrives: Time.zone.local(2024, 6, 10, 9, 0),
          departs: Time.zone.local(2024, 6, 14, 17, 0),
        )
      end

      sign_in(user)
      flow = ProjectSummaryFlow.new(page)

      flow.visit_show_page(project)

      expect(flow).to be_on_project_show_page
      expect(flow).to have_project_status("Open Project")
      expect(flow).to have_submitted_date(
        request_type: "Research Request",
        submitted_at: "May. 15, 2024 at 2:30 PM",
      )
      expect(flow).to have_navigation_link(text: "Edit Project", href: "/projects/#{project.id}/edit")
      expect(flow).to have_completed_sidebar
      expect(flow).to have_contact_reserve_form

      expect(flow).to have_summary_row(label: "Project Title", value: "Counting Newts")
      expect(flow).to have_summary_row(label: "Thesis Title", value: "Newts of the North Coast")
      expect(flow).to have_summary_row(label: "Project Abstract", value: "A study of newt migration.")
      expect(flow).to have_summary_row(label: "Applicant", value: "Taricha torosa")
      expect(flow).to have_summary_row(label: "Principal Investigators", value: "Taricha torosa")
      expect(flow).to have_summary_row(label: "Project Duration", value: "Jun 1 - Aug 31, 2024")
      expect(flow).to have_summary_row(label: "Discipline", value: "Ecology")
      expect(flow).to have_summary_row(label: "Project Involves", value: "Mammals and Birds")

      expect(flow).to have_method_statement("Remove organisms or materials from the reserve")
      expect(flow).to have_method_statement("Sodium chloride")
      expect(flow).to have_no_method_statement("Soil Disturbance")
      expect(flow).to have_method_detail(
        label: "Detailed description of environmental manipulations",
        value: "Counting newts by hand.",
      )
      expect(flow).to have_method_detail(
        label: "Reserve area(s) you plan to visit or conduct manipulations",
        value: "The creek bed.",
      )

      expect(flow).to have_no_files

      expect(flow).to have_section_heading("Project Team (2)")
      expect(flow).to have_navigation_link(text: "Edit Team", href: "/projects/#{project.id}/team_memberships")
      expect(flow).to have_team_member(
        name: "Taricha torosa",
        institution: "UC Berkeley",
        project_role: "PI - Principal Investigator",
      )
      expect(flow).to have_team_member(
        name: "Taricha sierrae",
        institution: "Newt University",
        project_role: "Team Member",
      )
      expect(flow).to have_no_team_member("Removed Member")

      expect(flow).to have_section_heading("Funding (1)")
      expect(flow).to have_navigation_link(text: "Edit Funding", href: "/projects/#{project.id}/fundings")
      expect(flow).to have_funding(
        title: "Newt Migration Grant",
        funding_agency: "National Science Foundation (NSF)",
        award_amount: "$25,000.00",
      )

      expect(flow).to have_section_heading("Permits")
      expect(flow).to have_navigation_link(text: "Edit Permits", href: "/projects/#{project.id}/questions")
      expect(flow).to have_permit(authority: "Federal", statement: "Holds a federal collecting permit")
      expect(flow).to have_permit(authority: "State", statement: "Holds a state scientific collecting permit")
      expect(flow).to have_no_permit("Holds a local permit")

      expect(flow).to have_section_heading("Additional Reserve Questions")
      expect(flow).to have_navigation_link(text: "Edit Reserve Questions", href: "/projects/#{project.id}/questions")
      expect(flow).to have_reserve_answer(
        reserve_name: "Angelo Coast Range Reserve",
        question: "Will you use a drone?",
        answer: "Plans to fly a drone",
      )
      expect(flow).to have_reserve_answer(
        reserve_name: "Sagehen Creek Field Station",
        question: "Which trails will you use?",
        answer: "The east ridge trail",
      )
      expect(flow).to have_no_reserve_answer("Will you camp overnight?")

      expect(flow).to have_section_heading("Visits (1)")
      expect(flow).to have_visits_count(1)
      expect(flow).to have_visit(
        status: "APPROVED",
        date_range: "Jun 10 - 14, 2024",
        reserve_name: "Angelo Coast Range Reserve",
        visitors_and_amenities: "1 Visitor, 2 Amenities",
      )

      expect(page).to be_axe_clean
    end
  end

  it "shows the incomplete sidebar for an incomplete project" do
    user = create(:user, :confirmed)
    project = create(:project, status: :incomplete, submitted_at: nil, owner: user, applicant: user)
    create(:project_team_membership, project: project, user: user, active: true)

    sign_in(user)
    flow = ProjectSummaryFlow.new(page)

    flow.visit_show_page(project)

    expect(flow).to be_on_project_show_page
    expect(flow).to have_project_status("Incomplete Project")
    expect(flow).to have_submitted_date(request_type: "Research Request", submitted_at: "Not yet submitted")
    expect(flow).to have_incomplete_sidebar
    expect(flow).to have_no_fundings
    expect(flow).to have_visits_count(0)
    expect(page).to be_axe_clean
  end

  it "emails reserve staff from the contact reserve form" do
    user = create(:user, :confirmed)
    reserve = create(:reserve, name: "Angelo Coast Range Reserve")
    project = create(:project, status: :open, reserve: reserve, owner: user, applicant: user)
    create(:project_team_membership, project: project, user: user, active: true)

    sign_in(user)
    flow = ProjectSummaryFlow.new(page)

    flow.visit_show_page(project)
    flow.contact_reserve("Angelo Coast Range Reserve")

    expect(flow).to have_flash_message(
      "An email has been sent to Angelo Coast Range Reserve staff regarding your request."
    )
    expect(flow).to be_on_project_show_page
    expect(page).to be_axe_clean
  end

  it "does not let a user who is not on the project team view it" do
    user = create(:user, :confirmed)
    project = create(:project)

    sign_in(user)
    flow = ProjectSummaryFlow.new(page)

    flow.visit_show_page(project)

    expect(flow).to be_on_home_page
    expect(flow).to have_flash_message("You are not authorized.")
    expect(page).to be_axe_clean
  end
end
