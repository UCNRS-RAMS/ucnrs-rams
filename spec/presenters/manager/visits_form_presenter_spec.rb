require "rails_helper"

RSpec.describe Manager::Visits::VisitsFormPresenter do
  let(:presenter) { Manager::Visits::VisitsFormPresenter.new(user: build(:user)) }

  describe "#project_type_partial_path" do
    it "should return project_type_partial_path" do
      expect(presenter.project_type_partial_path).to eq "manager/visits/detail/project_type"
    end
  end

  describe "#project_partial_path" do
    it "should return project_partial_path" do
      expect(presenter.project_partial_path).to eq "shared/visits/project"
    end
  end

  describe "#save_partial_path" do
    it "should return save_partial_path" do
      expect(presenter.save_partial_path).to eq "manager/visits/detail/save"
    end
  end

  describe "#reserve_partial_path" do
    it "should return reserve_select_field_partial_path" do
      expect(presenter.reserve_partial_path).to eq "shared/visits/reserve"
    end
  end

  describe "#show_browse_reserve_link" do
    it "should return false to hide browse reserve link" do
      expect(presenter.show_browse_reserve_link).to eq false
    end
  end

  describe "#project_summary_path" do
    it "should return manager_reserve_project_path" do
      form = VisitForm.new(params: { reserve_id: create(:reserve).id, project_id: create(:project).id })
      presenter = Manager::Visits::VisitsFormPresenter.new(user: build(:user), form: form)

      result = "/manager/reserves/#{form.reserve_id}/projects/#{form.project_id}"

      expect(presenter.project_summary_path).to eq result
    end
  end

  describe "#amenities_by_group_label" do
    let(:reserve) { create(:reserve, amenity_group_label_1: "Label 1", amenity_group_label_2: "Label 2") }
    let(:visit) { create(:visit, reserve: reserve) }
    let(:user) { create(:user) }

    it "should return amenity group labels as keys" do
      create(:amenity, reserve: reserve, group_number: "1")
      create(:amenity, reserve: reserve, group_number: "2")

      form = VisitForm.new(user: user, params: { id: visit.id })
      presenter = Manager::Visits::VisitsFormPresenter.new(user: user, form: form)

      expect(presenter.amenities_by_group_label.keys).to eq ["Label 1", "Label 2"]
    end

    it "should return amenity group labels for amenities which are not disabled as keys" do
      create(:amenity, reserve: reserve, group_number: "1", disable: true)
      create(:amenity, reserve: reserve, group_number: "2", disable: false)

      form = VisitForm.new(user: user, params: {
        id: visit.id,
      })
      presenter = Manager::Visits::VisitsFormPresenter.new(user: user, form: form)

      expect(presenter.amenities_by_group_label.keys).to eq ["Label 2"]
    end
  end

  describe "#message_text" do
    it "it return visits_reserve_approval_mesage text if visit_status is approved otherwise return nil" do
      user = create(:user, :confirmed)
      visit_incomplete = create(:visit)
      reserve = create(:reserve, approval_message: "reserve_approval_message_text")
      visit_approved = create(:visit, reserve: reserve, status: "approved")

      form1 = VisitForm.new(user: user, params: { id: visit_incomplete.id })
      form2 = VisitForm.new(user: user, params: { id: visit_approved.id })

      presenter1 = Manager::Visits::VisitsFormPresenter.new(user: user, form: form1)
      presenter2 = Manager::Visits::VisitsFormPresenter.new(user: user, form: form2)

      expect(presenter1.message_text).to be_nil
      expect(presenter2.message_text).to eq "reserve_approval_message_text"
    end
  end

  describe "#disabled?" do
    it "return true if visit_status is  incomplete" do
      user = create(:user, :confirmed)

      visit_incomplete = create(:visit, status: "incomplete")
      form = VisitForm.new(user: user, params: { id: visit_incomplete.id })
      presenter = Manager::Visits::VisitsFormPresenter.new(user: user, form: form)

      expect(presenter.status_bar_disabled?).to eq true
    end

    it "return false if visit_status is not incomplete" do
      user = create(:user, :confirmed)

      visit_approved = create(:visit, status: "approved")
      form = VisitForm.new(user: user, params: { id: visit_approved.id })
      presenter = Manager::Visits::VisitsFormPresenter.new(user: user, form: form)

      expect(presenter.status_bar_disabled?).to eq false
    end
  end

  describe "#email_options" do
    it "return a constant hash for email options" do
      presenter = Manager::Visits::VisitsFormPresenter.new(user: create(:user))

      expected_value = {
        "Send applicants a composed email" => :composed_email,
        "Silently update status" => :silently_update,
      }
      expect(presenter.email_options).to eq(expected_value)
    end
  end

  describe "#project_team_members" do
    it "return project_team_members" do
      user = create(:user, :confirmed)
      project = create(:project)
      team_members = create_list(:project_team_membership, 3, project: project)
      visit_approved = create(:visit, project: project, status: "approved")

      form = VisitForm.new(user: user, params: { id: visit_approved.id })
      presenter = Manager::Visits::VisitsFormPresenter.new(user: user, form: form)

      results = presenter.project_team_members

      expect(results.map(&:id)).to eq [
        team_members[0].id,
        team_members[1].id,
        team_members[2].id,
      ]

      expect(results).to all(be_instance_of Manager::Projects::TeamMembershipPresenter)
    end
  end
end
