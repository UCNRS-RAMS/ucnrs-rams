require "rails_helper"

RSpec.describe Mail::VisitPresenter do
  describe "delegations" do
    subject { Mail::VisitPresenter.new(build(:visit)) }
    it { is_expected.to delegate_missing_methods_to(:visit) }
  end

  describe "#applicant_name" do
    it "presents the visit applicant full name" do
      user = create(:user, first_name: "john", last_name: "doe")
      visit = create(:visit, user: user)
      presenter = Mail::VisitPresenter.new(visit)

      applicant_name = presenter.applicant_name

      expect(applicant_name).to eq "john doe"
    end
  end

  describe "#timeframe" do
    it "display a formatted visit summary start and end time" do
      starts_at = Time.zone.local(2004, 11, 24, 1, 4, 44)
      ends_at = Time.zone.local(2004, 11, 24, 1, 4, 44) + 1.day
      visit = create(:visit, starts_at: starts_at, ends_at: ends_at)
      presenter = Mail::VisitPresenter.new(visit)

      expect(presenter.timeframe).to eq "Nov. 24, 2004 at  1:04 AM - Nov. 25, 2004 at  1:04 AM"
    end
  end

  describe "#visitor_count" do
    it "display the sum count of all the user_visit" do
      visit = create(:visit)
      create(:user_visit, visit: visit, count: 1)
      create(:user_visit, visit: visit, count: 2)
      create(:user_visit, visit: visit, count: 3)
      presenter = Mail::VisitPresenter.new(visit)

      expect(presenter.visitor_count).to eq 6
    end
  end

  describe "#amenity_count" do
    it "display the sum of all the unique amenity_visit" do
      visit = create(:visit)
      amenity1 = create(:amenity)
      amenity2 = create(:amenity)
      create(:amenity_visit, visit: visit, amenity: amenity1)
      create(:amenity_visit, visit: visit, amenity: amenity2)
      create(:amenity_visit, visit: visit, amenity: amenity1)
      presenter = Mail::VisitPresenter.new(visit)

      expect(presenter.amenity_count).to eq 2
    end
  end

  describe "#amenities_total" do
    it "display the total of all the amenity_visits subtotal amount" do
      visit = create(:visit)
      create(:amenity_visit, visit: visit, number_of_people: 10, manual_units_of_time: 10, rate: 10)
      create(:amenity_visit, visit: visit, number_of_people: 10, manual_units_of_time: 10, rate: 10)
      presenter = Mail::VisitPresenter.new(visit)

      expect(presenter.amenities_total).to eq "$2000.00"
    end
  end

  describe "#visit_type" do
    it "display formatted visit type from the project" do
      project = create(:project, project_type: :research)
      visit = create(:visit, project: project)
      presenter = Mail::VisitPresenter.new(visit)

      expect(presenter.visit_type).to eq "Research"
    end

    it "display formatted visit type for class" do
      project = create(:project, project_type: :class)
      visit = create(:visit, project: project)
      presenter = Mail::VisitPresenter.new(visit)

      expect(presenter.visit_type).to eq "Class"
    end

    it "display formatted visit type for meeting" do
      project = create(:project, project_type: :meeting)
      visit = create(:visit, project: project)
      presenter = Mail::VisitPresenter.new(visit)

      expect(presenter.visit_type).to eq "Meeting or Conference"
    end

    it "display formatted visit type for public use" do
      project = create(:project, project_type: :public_use)
      visit = create(:visit, project: project)
      presenter = Mail::VisitPresenter.new(visit)

      expect(presenter.visit_type).to eq "Public Use"
    end

    it "displays not applicable when project is nil" do
      visit = build(:visit)
      visit.project = nil
      presenter = Mail::VisitPresenter.new(visit)

      expect(presenter.visit_type).to eq I18n.t("not_applicable")
    end
  end

  describe "#visit_reserve" do
    it "presents the visit reserve wrapped in ReservePresenter" do
      reserve = create(:reserve)
      visit = create(:visit, reserve: reserve)
      presenter = Mail::VisitPresenter.new(visit)

      visit_reserve = presenter.visit_reserve

      expect(visit_reserve).to be_a(ReservePresenter)
      expect(visit_reserve.id).to eq reserve.id
    end
  end

  describe "#visit_applicant" do
    it "presents the visit applicant wrapped in UserPresenter" do
      user = create(:user)
      visit = create(:visit, user: user)
      presenter = Mail::VisitPresenter.new(visit)

      visit_applicant = presenter.visit_applicant

      expect(visit_applicant).to be_a(UserPresenter)
      expect(visit_applicant.id).to eq user.id
    end
  end

  describe "#visit_reserve_managing_campus" do
    it "presents the visit reserve managing_campus wrapped in InstitutionPresenter" do
      institution = create(:institution)
      reserve = create(:reserve, managing_campus: institution)
      visit = create(:visit, reserve: reserve)
      presenter = Mail::VisitPresenter.new(visit)

      visit_reserve_managing_campus = presenter.visit_reserve_managing_campus

      expect(visit_reserve_managing_campus).to be_a(InstitutionPresenter)
      expect(visit_reserve_managing_campus.id).to eq institution.id
    end
  end

  describe "#visit_project" do
    it "presents the visit project wrapped in ProjectPresenter" do
      project = create(:project)
      visit = create(:visit, project: project)
      presenter = Mail::VisitPresenter.new(visit)

      visit_project = presenter.visit_project

      expect(visit_project).to be_a(ProjectPresenter)
      expect(visit_project.id).to eq project.id
    end
  end

  describe "#user_visits" do
    it "presents the visit user_visits wrapped in UserVisitPresenter" do
      user_visit1 = create(:user_visit)
      user_visit2 = create(:user_visit)
      visit = create(:visit, user_visits: [user_visit1, user_visit2])
      presenter = Mail::VisitPresenter.new(visit)

      user_visits = presenter.user_visits

      expect(user_visits).to all(be_a(UserVisitPresenter))
      expect(user_visits.map(&:id)).to match_array [user_visit1.id, user_visit2.id]
    end
  end

  describe "#amenity_visits" do
    it "presents the visit amenity_visits wrapped in AmenityVisitPresenter" do
      amenity_visit1 = create(:amenity_visit)
      amenity_visit2 = create(:amenity_visit)
      visit = create(:visit, amenity_visits: [amenity_visit1, amenity_visit2])
      presenter = Mail::VisitPresenter.new(visit)

      amenity_visits = presenter.amenity_visits

      expect(amenity_visits).to all(be_a(AmenityVisitPresenter))
      expect(amenity_visits.map(&:id)).to match_array [amenity_visit1.id, amenity_visit2.id]
    end
  end
end
