require "rails_helper"

RSpec.describe VisitShowPresenter do
  describe "delegations" do
    subject { VisitShowPresenter.new(build(:visit)) }
    it { is_expected.to delegate_method(:id).to(:visit_reserve).with_prefix(true) }
    it { is_expected.to delegate_method(:name).to(:visit_reserve).with_prefix(true) }
    it { is_expected.to delegate_method(:address_line_1).to(:visit_reserve).with_prefix(true) }
    it { is_expected.to delegate_method(:address_line_2).to(:visit_reserve).with_prefix(true) }
    it { is_expected.to delegate_method(:address_line_3).to(:visit_reserve).with_prefix(true) }
    it { is_expected.to delegate_method(:address_city).to(:visit_reserve).with_prefix(true) }
    it { is_expected.to delegate_method(:address_postal_code).to(:visit_reserve).with_prefix(true) }
    it { is_expected.to delegate_method(:state).to(:visit_reserve).with_prefix(true) }
    it { is_expected.to delegate_method(:country).to(:visit_reserve).with_prefix(true) }
    it { is_expected.to delegate_method(:avatar).to(:visit_reserve).with_prefix(true) }
    it { is_expected.to delegate_method(:email_address).to(:visit_reserve).with_prefix(true) }
    it { is_expected.to delegate_method(:listing_photo_placeholder).to(:visit_reserve).with_prefix(true) }
    it { is_expected.to delegate_method(:managing_campus).to(:visit_reserve).with_prefix(true) }
    it { is_expected.to delegate_method(:reserve_alert_message).to(:visit_reserve).with_prefix(true) }
    it { is_expected.to delegate_method(:rules).to(:visit_reserve).with_prefix(true) }
    it { is_expected.to delegate_method(:rules_url).to(:visit_reserve).with_prefix(true) }
    it { is_expected.to delegate_method(:id).to(:visit).with_prefix(true) }
    it { is_expected.to delegate_method(:title).to(:project).with_prefix(true) }
    it { is_expected.to delegate_method(:project_type).to(:project).with_prefix(true) }
    it { is_expected.to delegate_missing_methods_to(:visit) }
  end

  describe "#reserve_email" do
    it "returns visit's reserve email address" do
      reserve = create(:reserve, email_address: "test@example.com")
      visit = create(:visit, reserve: reserve)
      presenter = VisitShowPresenter.new(visit)

      expect(presenter.reserve_email).to eq "test@example.com"
    end
  end

  describe "#sidebar_partial_name" do
    it "returns the sidebar partial path based on visit status" do
      visit = create(:visit, status: :approved)
      presenter = VisitShowPresenter.new(visit)

      expect(presenter.sidebar_partial_name).to eq "visits/sidebar_approved_show"
    end
  end

  describe "#outside_reservation_system_url" do
    it "returns the outside_reservation_system_url if not equal to '0'" do
      reserve = create(:reserve, outside_reservation_system_url: "https://rams3-dev.ucnrs.org/")
      visit = create(:visit, status: :approved, reserve: reserve)
      presenter = VisitShowPresenter.new(visit)

      expect(presenter.outside_reservation_system_url).to eq "https://rams3-dev.ucnrs.org/"
    end

    it "returns 'nil' if equal to '0'" do
      reserve = create(:reserve, outside_reservation_system_url: "0")
      visit = create(:visit, status: :approved)
      presenter = VisitShowPresenter.new(visit)

      expect(presenter.outside_reservation_system_url).to be_nil
    end
  end
  

  describe "#edit_button?" do
    it "returns 'true' if visit start_date greater then today's date and visit status is 'in_review'" do
      visit = create(:visit, status: :in_review, starts_at: Time.current.tomorrow)
      presenter = VisitShowPresenter.new(visit)

      expect(presenter.edit_button?).to be_truthy
    end

    it "returns 'false' if visit start_date less then today's date and visit status is not 'in_review'" do
      visit = create(:visit, status: :in_review, starts_at: Time.current.yesterday)
      presenter = VisitShowPresenter.new(visit)

      expect(presenter.edit_button?).to be_falsy
    end
  end

  describe "#reserve_answers" do
    it "creates a VisitReserveAnswer for each visit_reserve_answer" do
      visit = create(:visit)
      visit_reserve_answers = create_list(:visit_reserve_answer, 3, visit: visit, boolean_answer: true)
      presenter = VisitShowPresenter.new(visit)

      results = presenter.reserve_answers

      expect(results.values.flatten.map(&:id)).to eq [
        visit_reserve_answers[0].id,
        visit_reserve_answers[1].id,
        visit_reserve_answers[2].id,
      ]
    end
  end

  describe "#content_partial_name" do
    context "when the visit status is approved" do
      it "returns the content partial path visits/content_approved_show" do
        visit = create(:visit, status: :approved)
        presenter = VisitShowPresenter.new(visit)

        expect(presenter.content_partial_name).to eq "visits/content_approved_show"
      end
    end

    context "when the visit status is not approved" do
      it "returns the content partial path visits/content_show" do
        visit = create(:visit, status: :in_review)
        presenter = VisitShowPresenter.new(visit)

        expect(presenter.content_partial_name).to eq "visits/content_show"
      end
    end
  end

  describe "#status_classes" do
    it "display status text color based on status value" do
      user = create(:user, :confirmed)
      pending_visit = create(:visit, status: "in_review")
      approved_visit = create(:visit, status: "approved")
      cancelled_visit = create(:visit, status: "cancelled")
      denied_visit = create(:visit, status: "denied")

      pending_show_presenter = VisitShowPresenter.new(pending_visit)
      approved_show_presenter = VisitShowPresenter.new(approved_visit)
      cancelled_show_presenter = VisitShowPresenter.new(cancelled_visit)
      denied_show_presenter = VisitShowPresenter.new(denied_visit)

      expect(pending_show_presenter.status_classes).to eq "btn-status bg-in_review"
      expect(approved_show_presenter.status_classes).to eq "btn-status bg-approved"
      expect(cancelled_show_presenter.status_classes).to eq "btn-status bg-cancelled"
      expect(denied_show_presenter.status_classes).to eq "btn-status bg-denied"
    end
  end

  describe "#status_text" do
    it "converts underscores in the visit status to spaces and capitalizes the first letter word" do
      visit_presenter = VisitShowPresenter.new(create(:visit, status: :in_review))

      expect(visit_presenter.status_text).to eq "In review"
    end
  end

  describe "#visit_reserve_personnel" do
    it "creates a ReservePersonnelPresenter for each visit reserve personnel" do
      reserve = create(:reserve)
      reserve_personnel = create_list(:reserve_personnel, 3, reserve: reserve)
      visit = create(:visit, reserve: reserve)
      presenter = VisitShowPresenter.new(visit)

      results = presenter.visit_reserve_personnel

      expect(results.map(&:id)).to eq [
        reserve_personnel[0].id,
        reserve_personnel[1].id,
        reserve_personnel[2].id,
      ]
    end
  end

  describe "#applicant_name" do
    it "returns the full name of the user applicant for the visit" do
      user = create(:user, first_name: "Homer", last_name: "Simpson")
      visit = create(:visit, user: user)
      presenter = VisitShowPresenter.new(visit)

      expect(presenter.applicant_name).to eq "Homer Simpson"
    end
  end

  describe "#submitted_at" do
    it "display a formatted submission datetime of the visit" do
      travel_to Time.zone.local(2004, 11, 24, 1, 4, 44)
      visit = create(:visit, submitted_at: Time.current)
      presenter = VisitShowPresenter.new(visit)

      expect(presenter.submitted_at).to eq "Nov. 24, 2004 at  1:04 AM"
    end
  end

  describe "#timeframe" do
    it "display a formatted visit summary start and end time" do
      starts_at = Time.zone.local(2004, 11, 24, 1, 4, 44)
      ends_at = Time.zone.local(2004, 11, 24, 1, 4, 44) + 1.day
      visit = create(:visit, starts_at: starts_at, ends_at: ends_at)
      presenter = VisitShowPresenter.new(visit)

      expect(presenter.timeframe).to eq "Nov. 24, 2004 at  1:04 AM - Nov. 25, 2004 at  1:04 AM"
    end
  end

  describe "#project_type" do
    it "display formated string of the visit project type" do
      project = create(:project, project_type: :research)
      visit = create(:visit, project: project)
      presenter = VisitShowPresenter.new(visit)

      expect(presenter.project_type).to eq "Research Project"
    end
  end

  describe "#visitor_count" do
    it "display the sum count of all the user_visit" do
      visit = create(:visit)
      create(:user_visit, visit: visit, count: 1)
      create(:user_visit, visit: visit, count: 2)
      create(:user_visit, visit: visit, count: 3)
      presenter = VisitShowPresenter.new(visit)

      expect(presenter.visitor_count).to eq 6
    end
  end

  describe "#amenity_count" do
    #visit.amenity_visits.pluck(:amenity_id).uniq.length
    it "display the sum of all the unique amenity_visit" do
      visit = create(:visit)
      amenity1 = create(:amenity)
      amenity2 = create(:amenity)
      create(:amenity_visit, visit: visit, amenity: amenity1)
      create(:amenity_visit, visit: visit, amenity: amenity2)
      create(:amenity_visit, visit: visit, amenity: amenity1)
      presenter = VisitShowPresenter.new(visit)

      expect(presenter.amenity_count).to eq 2
    end
  end

  describe "#user_visits" do
    it "creates a UserVisitPresenter for each visit user_visit" do
      visit = create(:visit)
      user_visit = create_list(:user_visit, 3, visit: visit)
      presenter = VisitShowPresenter.new(visit)

      results = presenter.user_visits

      expect(results.map(&:id)).to eq [
        user_visit[0].id,
        user_visit[1].id,
        user_visit[2].id,
      ]
    end
  end

  describe "#amenity_visits" do
    it "creates a AmenityVisitPresenter for each visit amenity_visit" do
      visit = create(:visit)
      amenity_visit = create_list(:amenity_visit, 3, visit: visit)
      presenter = VisitShowPresenter.new(visit)

      results = presenter.amenity_visits

      expect(results.map(&:id)).to eq [
        amenity_visit[0].id,
        amenity_visit[1].id,
        amenity_visit[2].id,
      ]
    end
  end

  describe "#reserve_waivers" do
    it "creates a WaiverPresenter for each visit reserve waiver" do
      reserve = create(:reserve)
      waiver = create_list(:waiver, 3, reserves: [reserve])
      visit = create(:visit, reserve: reserve)
      presenter = VisitShowPresenter.new(visit)

      results = presenter.reserve_waivers

      expect(results.map(&:id)).to eq [
        waiver[0].id,
        waiver[1].id,
        waiver[2].id,
      ]
    end
  end

  describe "#amenities_total" do
    it "display the total of all the amenity_visits subtotal amount" do
      visit = create(:visit)
      create(:amenity_visit, visit: visit, number_of_people: 10, manual_units_of_time: 10, rate: 10)
      create(:amenity_visit, visit: visit, number_of_people: 10, manual_units_of_time: 10, rate: 10)
      presenter = VisitShowPresenter.new(visit)

      expect(presenter.amenities_total).to eq "$2000.00"
    end
  end
end
