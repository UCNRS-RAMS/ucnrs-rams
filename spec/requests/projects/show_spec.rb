require "rails_helper"

RSpec.describe ProjectsController, type: :request do
  describe "GET /projects/:id" do
    it "renders the project summary for an active team member" do
      user = create(:user, :confirmed, first_name: "Taricha", last_name: "torosa")
      reserve = create(:reserve, name: "Angelo Coast Range Reserve")
      project = create(
        :project,
        reserve: reserve,
        applicant: user,
        owner: user,
        status: :open,
        project_type: :research,
        title: "Counting Newts",
      )
      create(
        :project_team_membership,
        :principal_investigator,
        project: project,
        user: user,
        active: true,
      )
      create(
        :project_team_membership,
        :team_member,
        project: project,
        user: create(:user, :confirmed, first_name: "Taricha", last_name: "sierrae"),
        active: true,
      )
      create(
        :project_team_membership,
        :team_member,
        project: project,
        user: create(:user, :confirmed, first_name: "Removed", last_name: "Member"),
        active: false,
      )
      create(:funding, project: project, title: "Newt Migration Grant")
      permit = create(
        :permit,
        authority: "Federal",
        statement: "Holds a federal collecting permit",
      )
      create(:project_permit_answer, project: project, permit: permit, answer: true)
      reserve_question = create(
        :reserve_question,
        :boolean_question,
        reserve: reserve,
        question: "Will you use a drone?",
        statement: "Plans to fly a drone",
      )
      create(
        :project_reserve_answer,
        project: project,
        reserve_question: reserve_question,
        boolean_answer: true,
      )
      create(
        :visit,
        project: project,
        reserve: reserve,
        user: user,
        status: :approved,
        start_date: Date.new(2024, 6, 10),
        end_date: Date.new(2024, 6, 14),
      )
      sign_in(user)

      get "/projects/#{project.id}"

      doc = Capybara.string(response.body)
      expect(response).to be_ok
      expect(doc).to have_css("body.projects-show")
      expect(doc).to have_css("section.sidebar")
      expect(doc).to have_css("#project-contact-reserve")
      expect(doc).to have_css(".project-summary")
      expect(doc).to have_css("#team-summary-table tr.team-membership", count: 2)
      expect(doc).to have_link("Edit Project", href: "/projects/#{project.id}/edit")
      expect(doc).to have_link("Edit Team", href: "/projects/#{project.id}/team_memberships")
      expect(doc).to have_link("Edit Funding", href: "/projects/#{project.id}/fundings")
      expect(doc).to have_link("Edit Permits", href: "/projects/#{project.id}/questions")
      expect(doc).to have_css("#funding-summary-table tr.funding", count: 1)
      expect(doc).to have_css("#permit-summary-list li", text: "Holds a federal collecting permit")
      expect(doc).to have_css("#reserve_question-summary-list .question-answer")
      expect(doc).to have_css("#project-visit-requests tr.visit", count: 1)
    end

    it "renders the incomplete sidebar for a project that has not been submitted" do
      user = create(:user, :confirmed)
      project = create(
        :project,
        status: :incomplete,
        submitted_at: nil,
        owner: user,
        applicant: user,
      )
      create(:project_team_membership, project: project, user: user, active: true)
      sign_in(user)

      get "/projects/#{project.id}"

      doc = Capybara.string(response.body)
      expect(response).to be_ok
      expect(doc).to have_css("section.sidebar header.incomplete")
      expect(doc).to have_no_css("#project-contact-reserve")
      expect(doc).to have_css("#funding-summary-table", text: "No Funding")
      expect(doc).to have_css("#project-visit-requests tr.visit", count: 0)
      expect(doc).to have_text("Incomplete Project")
    end

    it "redirects a user who is not on the project team" do
      user = create(:user, :confirmed)
      project = create(:project)
      sign_in(user)

      get "/projects/#{project.id}"

      expect(response).to redirect_to(home_index_path)
      expect(flash[:alert]).to eq "You are not authorized."
    end
  end

  describe "POST /projects/:project_id/contact_manager" do
    it "emails the reserve staff and confirms the message was sent" do
      user = create(:user, :confirmed)
      reserve = create(:reserve, name: "Angelo Coast Range Reserve")
      project = create(:project, status: :open, reserve: reserve, owner: user, applicant: user)
      create(:project_team_membership, project: project, user: user, active: true)
      sign_in(user)

      expect do
        post "/projects/#{project.id}/contact_manager", params: {
          email_manager: { reserve_id: reserve.id }
        }
      end.to have_enqueued_mail(UserMailer, :project_contact_manager)

      expect(response).to redirect_to(project_path(project))

      follow_redirect!

      expect(response).to be_ok
      expect(Capybara.string(response.body)).to have_text(
        "An email has been sent to Angelo Coast Range Reserve staff regarding your request.",
      )
    end
  end
end
