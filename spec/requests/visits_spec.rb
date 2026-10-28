require "rails_helper"

RSpec.describe VisitsController, type: :request do
  let(:user) { create(:user, :confirmed) }
  let(:reserve) do
    create(
      :reserve,
      name: "Silver Lake Area",
      special_needs_statement: "Tell us!",
      reserve_alert_message_enabled: true,
      reserve_alert_message: "Alert!",
      class_projects_accepted: true,
      amenity_group_label_1: "Fun Things"
    )
  end
  let(:project) do
    create(:project, title: "Fun", project_type: "class", reserve: reserve, owner: user)
  end

  before do
    create(:project_team_membership, project: project, user: user, active: true, can_add_visit: true)
    sign_in(user)
  end

  describe "GET /visits/new" do
    it "renders the visit request form" do
      get "/visits/new"

      expect(response).to be_ok

      doc = Capybara.string(response.body)
      expect(doc).to have_css("body.visits-new")
      expect(doc).to have_css("form#visits-new")
      expect(doc).to have_select("visit_project_id", with_options: [ "Class - Fun" ])
      expect(doc).to have_select("visit_reserve_id")
      expect(doc).to have_field("visit_purpose_of_visit")
      expect(doc).to have_field("visit_start_date")
      expect(doc).to have_field("visit_end_date")
    end

    it "lists the reserves and amenities that accept the selected project's project type" do
      amenity = create(:amenity, title: "Beach Access", reserve: reserve, group_number: "1")
      rate_category = create(:amenity_rate_category, reserve: reserve, state_university: true)
      create(:amenity_rate, amenity: amenity, amenity_rate_category: rate_category)

      get "/visits/new", params: { visit: { project_id: project.id, reserve_id: reserve.id } }

      expect(response).to be_ok

      doc = Capybara.string(response.body)
      expect(doc).to have_select("visit_project_id", selected: "Class - Fun")
      expect(doc).to have_select("visit_reserve_id", with_options: [ "Silver Lake Area" ])
      expect(doc).to have_css("small.special-needs-statement", text: "Tell us!")
      expect(doc).to have_css("div.reserve-message", text: "Alert!")
      expect(doc).to have_css("header", text: "Fun Things")
      expect(doc).to have_css("div.amenity h3", text: "Beach Access")
    end

    it "requires the user to be signed in" do
      sign_out(user)

      get "/visits/new"

      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe "POST /visits" do
    let(:amenity) { create(:amenity, title: "Beach Access", reserve: reserve, group_number: "1") }
    let!(:amenity_rate) { create(:amenity_rate, amenity: amenity, rate: 10) }

    def valid_visit_params
      {
        project_id: project.id,
        project_type: "university_class",
        reserve_id: reserve.id,
        purpose_of_visit: "To swim",
        start_date: 1.day.from_now.strftime("%Y-%m-%d"),
        start_time: "12:00",
        end_date: 2.days.from_now.strftime("%Y-%m-%d"),
        end_time: "12:00",
        special_needs: "None",
        study_area: "The lake shore",
        amenities: {
          amenity.id.to_s => {
            amenity_id: amenity.id.to_s,
            amenity_rate_id: amenity_rate.id,
            amenity_visits: {
              "0" => {
                arrives_on: 1.day.from_now.strftime("%Y-%m-%d"),
                arrives_at: "12:00",
                departs_on: 2.days.from_now.strftime("%Y-%m-%d"),
                departs_at: "12:00",
                number_of_people: 2
              }
            }
          }
        }
      }
    end

    it "creates the visit with the selected amenities" do
      expect do
        post "/visits", params: { visit: valid_visit_params }
      end.to change(Visit, :count).by(1)
        .and change(AmenityVisit, :count).by(1)

      visit = Visit.find_by!(purpose_of_visit: "To swim")
      expect(visit.user).to eq(user)
      expect(visit.project).to eq(project)
      expect(visit.reserve).to eq(reserve)
      expect(visit.special_needs).to eq("None")
      expect(visit.study_area).to eq("The lake shore")

      amenity_visit = visit.amenity_visits.first
      expect(amenity_visit.amenity).to eq(amenity)
      expect(amenity_visit.number_of_people).to eq(2)

      expect(response).to redirect_to(visit_user_visits_path(visit, format: :html))
    end

    it "re-renders the form with field errors when required values are missing" do
      expect do
        post "/visits", params: {
          visit: {
            project_id: "",
            reserve_id: "",
            purpose_of_visit: "",
            start_date: "",
            end_date: ""
          }
        }
      end.not_to change(Visit, :count)

      expect(response).to have_http_status(:unprocessable_content)

      doc = Capybara.string(response.body)
      expect(doc).to have_css("body.visits-create")
      expect(doc).to have_css("form#visits-new")
      expect(doc).to have_css(".error_messages", text: I18n.t("activerecord.errors.messages.blank"))
      expect(doc).to have_css(".error_messages", text: "must exist")
    end

    it "preserves the submitted selections when the form is re-rendered" do
      post "/visits", params: { visit: valid_visit_params.merge(purpose_of_visit: "") }

      expect(response).to have_http_status(:unprocessable_content)

      doc = Capybara.string(response.body)
      expect(doc).to have_css(".error_messages", text: I18n.t("activerecord.errors.messages.blank"))
      expect(doc).to have_select("visit_project_id", selected: "Class - Fun")
      expect(doc).to have_select("visit_reserve_id", selected: "Silver Lake Area")
      expect(doc).to have_field("visit[special_needs]", with: "None")
      expect(doc).to have_field("visit[study_area]", with: "The lake shore")
      expect(doc).to have_checked_field("visit[amenities][#{amenity.id}][amenity_id]")
    end

    it "requires the user to be signed in" do
      sign_out(user)

      expect do
        post "/visits", params: { visit: valid_visit_params }
      end.not_to change(Visit, :count)

      expect(response).to redirect_to(new_user_session_path)
    end
  end
end
