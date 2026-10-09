require "rails_helper"

RSpec.describe Calendar::ReserveSchedule do
  let(:date_range) { Date.new(2026, 4, 26)..Date.new(2026, 6, 6) }

  def schedule(reserve:, **params)
    described_class.new(reserve: reserve, date_range: date_range, **params)
  end

  def approved_visit(reserve:, user:, from:, to:, count: 1)
    visit = create(:visit, reserve: reserve, status: :approved,
      starts_at: from.in_time_zone, ends_at: to.in_time_zone.end_of_day)
    create(:user_visit, visit: visit, user: user, status: :approved,
      count: count, arrives_at: from.in_time_zone, departs_at: to.in_time_zone.end_of_day)
    visit
  end

  let(:reserve) { create(:reserve) }
  let(:user) { create(:user, :confirmed) }

  describe "#entries" do
    it "is empty when no reserve is in scope" do
      expect(schedule(reserve: nil).entries).to eq []
    end

    it "is empty when no status is selected" do
      approved_visit(reserve: reserve, user: user,
        from: Date.new(2026, 5, 4), to: Date.new(2026, 5, 6))

      expect(schedule(reserve: reserve, statuses: []).entries).to eq []
    end

    it "returns every kind and status when nothing narrows it" do
      row_status_for = { approved: :approved, in_review: :in_review, incomplete: :approved,
                         cancelled: :cancelled, denied: :denied }
      row_status_for.each do |visit_status, row_status|
        visit = create(:visit, reserve: reserve, status: visit_status,
          starts_at: Date.new(2026, 5, 4).in_time_zone,
          ends_at: Date.new(2026, 5, 6).in_time_zone.end_of_day)
        create(:user_visit, visit: visit, user: user, status: row_status,
          arrives_at: Date.new(2026, 5, 4).in_time_zone,
          departs_at: Date.new(2026, 5, 6).in_time_zone.end_of_day)
        create(:amenity_visit, visit: visit, user: user, status: row_status,
          arrives: Date.new(2026, 5, 4).in_time_zone,
          departs: Date.new(2026, 5, 6).in_time_zone.end_of_day)
      end

      entries = schedule(reserve: reserve).entries

      expect(entries.map { |entry| [ entry.kind, entry.status ] })
        .to match_array Calendar::Entry::KINDS.product(Calendar::Entry::STATUSES)
    end

    it "builds only the kinds it is asked for" do
      approved_visit(reserve: reserve, user: user,
        from: Date.new(2026, 5, 4), to: Date.new(2026, 5, 6))

      entries = schedule(reserve: reserve, kinds: [ :user ]).entries

      expect(entries.map(&:kind).uniq).to eq [ :user ]
    end

    it "drops rows whose status is not selected" do
      approved_visit(reserve: reserve, user: user,
        from: Date.new(2026, 5, 4), to: Date.new(2026, 5, 6))

      entries = schedule(reserve: reserve, statuses: [ :in_review, :incomplete ]).entries

      expect(entries).to eq []
    end

    it "keeps only the amenity rows in the groups it is given" do
      visit = approved_visit(reserve: reserve, user: user,
        from: Date.new(2026, 5, 4), to: Date.new(2026, 5, 6))
      in_group = create(:amenity_visit, visit: visit, user: user, status: :approved,
        amenity: create(:amenity, reserve: reserve, group_number: "2"),
        arrives: Date.new(2026, 5, 4).in_time_zone,
        departs: Date.new(2026, 5, 6).in_time_zone.end_of_day)
      create(:amenity_visit, visit: visit, user: user, status: :approved,
        amenity: create(:amenity, reserve: reserve, group_number: "3"),
        arrives: Date.new(2026, 5, 4).in_time_zone,
        departs: Date.new(2026, 5, 6).in_time_zone.end_of_day)

      amenity_rows = schedule(reserve: reserve, groups: [ "2" ]).entries.select(&:amenity?)

      expect(amenity_rows.map(&:id)).to eq [ in_group.id ]
    end

    it "excludes visits outside the range it was given" do
      approved_visit(reserve: reserve, user: user,
        from: Date.new(2026, 9, 4), to: Date.new(2026, 9, 6))

      expect(schedule(reserve: reserve).entries).to eq []
    end

    it "builds entries with no href because the presenter attaches it later" do
      approved_visit(reserve: reserve, user: user,
        from: Date.new(2026, 5, 4), to: Date.new(2026, 5, 6))

      expect(schedule(reserve: reserve).entries).to all(have_attributes(href: nil))
    end

    it "renders a gap in a visit as two bars, not one spanning bar" do
      visit = create(:visit, reserve: reserve, status: :approved,
        starts_at: Date.new(2026, 5, 1).in_time_zone,
        ends_at: Date.new(2026, 5, 12).in_time_zone.end_of_day)
      create(:user_visit, visit: visit, user: user, status: :approved,
        arrives_at: Date.new(2026, 5, 1).in_time_zone,
        departs_at: Date.new(2026, 5, 3).in_time_zone.end_of_day)
      create(:amenity_visit, visit: visit, user: user, status: :approved,
        arrives: Date.new(2026, 5, 10).in_time_zone,
        departs: Date.new(2026, 5, 12).in_time_zone.end_of_day)

      visit_rows = schedule(reserve: reserve).entries.select(&:visit?)

      expect(visit_rows.size).to eq 2
      expect(visit_rows.map(&:starts_on)).to eq [ Date.new(2026, 5, 1), Date.new(2026, 5, 10) ]
      expect(visit_rows.map(&:ends_on)).to eq [ Date.new(2026, 5, 3), Date.new(2026, 5, 12) ]
    end

    it "labels a visit row with its purpose and id" do
      visit = approved_visit(reserve: reserve, user: user,
        from: Date.new(2026, 5, 4), to: Date.new(2026, 5, 6))
      visit.update!(purpose_of_visit: "Vernal pool sampling")

      visit_row = schedule(reserve: reserve).entries.find(&:visit?)

      expect(visit_row.title).to eq "Vernal pool sampling [Visit ##{visit.id}]"
    end

    it "squishes a purpose typed across several lines" do
      visit = approved_visit(reserve: reserve, user: user,
        from: Date.new(2026, 5, 4), to: Date.new(2026, 5, 6))
      visit.update!(purpose_of_visit: "Vernal pool\n\nsampling")

      visit_row = schedule(reserve: reserve).entries.find(&:visit?)

      expect(visit_row.title).to eq "Vernal pool sampling [Visit ##{visit.id}]"
    end

    it "caps a long purpose rather than carrying the whole column" do
      visit = approved_visit(reserve: reserve, user: user,
        from: Date.new(2026, 5, 4), to: Date.new(2026, 5, 6))
      visit.update!(purpose_of_visit: "Sampling " * 40)

      visit_row = schedule(reserve: reserve).entries.find(&:visit?)

      expect(visit_row.title).to start_with("Sampling Sampling")
      expect(visit_row.title).to end_with("… [Visit ##{visit.id}]")
      expect(visit_row.title.length).to be <= described_class::TITLE_LIMIT + " [Visit ##{visit.id}]".length
    end

    it "falls back to the bare id when a visit has no purpose" do
      visit = approved_visit(reserve: reserve, user: user,
        from: Date.new(2026, 5, 4), to: Date.new(2026, 5, 6))
      visit.update_column(:purpose_of_visit, "  ") # rubocop:disable Rails/SkipsModelValidations

      visit_row = schedule(reserve: reserve).entries.find(&:visit?)

      expect(visit_row.title).to eq "Visit ##{visit.id}"
    end

    it "gives every segment of one visit the same visit_id" do
      visit = create(:visit, reserve: reserve, status: :approved,
        starts_at: Date.new(2026, 5, 1).in_time_zone,
        ends_at: Date.new(2026, 5, 12).in_time_zone.end_of_day)
      create(:user_visit, visit: visit, user: user, status: :approved,
        arrives_at: Date.new(2026, 5, 1).in_time_zone,
        departs_at: Date.new(2026, 5, 3).in_time_zone.end_of_day)
      create(:amenity_visit, visit: visit, user: user, status: :approved,
        arrives: Date.new(2026, 5, 10).in_time_zone,
        departs: Date.new(2026, 5, 12).in_time_zone.end_of_day)

      visit_rows = schedule(reserve: reserve).entries.select(&:visit?)

      expect(visit_rows.map(&:visit_id).uniq.size).to eq 1
      expect(visit_rows.map(&:id).uniq.size).to eq 2
    end

    context "with user_visits" do
      let(:visit) do
        create(:visit, reserve: reserve, status: :approved,
          starts_at: Date.new(2026, 5, 1).in_time_zone,
          ends_at: Date.new(2026, 5, 12).in_time_zone.end_of_day)
      end

      def user_visit_on(visit, from:, to:, status: :approved, count: 1)
        create(:user_visit, visit: visit, user: user, status: status, count: count,
          arrives_at: from.in_time_zone, departs_at: to.in_time_zone.end_of_day)
      end

      def user_rows
        schedule(reserve: reserve).entries.select(&:user?)
      end

      it "builds one row per user_visit, dated by its own arrival and departure" do
        first = user_visit_on(visit, from: Date.new(2026, 5, 2), to: Date.new(2026, 5, 3))
        second = user_visit_on(visit, from: Date.new(2026, 5, 4), to: Date.new(2026, 5, 6))

        expect(user_rows).to contain_exactly(
          have_attributes(id: first.id, visit_id: visit.id,
            starts_on: Date.new(2026, 5, 2), ends_on: Date.new(2026, 5, 3)),
          have_attributes(id: second.id, visit_id: visit.id,
            starts_on: Date.new(2026, 5, 4), ends_on: Date.new(2026, 5, 6)),
        )
      end

      it "labels a single visitor with their name" do
        user_visit_on(visit, from: Date.new(2026, 5, 4), to: Date.new(2026, 5, 6))

        expect(user_rows.first.title).to eq user.full_name
      end

      it "labels a group with its role and headcount" do
        user_visit_on(visit, from: Date.new(2026, 5, 4), to: Date.new(2026, 5, 6), count: 3)

        expect(user_rows.first.title).to eq "Faculty (3)"
      end

      it "takes its status from the user_visit rather than the visit" do
        user_visit_on(visit, from: Date.new(2026, 5, 4), to: Date.new(2026, 5, 6), status: :cancelled)

        expect(user_rows.first.status).to eq :cancelled
      end

      it "is incomplete whenever its visit is incomplete" do
        visit.update!(status: :incomplete)
        user_visit_on(visit, from: Date.new(2026, 5, 4), to: Date.new(2026, 5, 6))

        expect(user_rows.first.status).to eq :incomplete
      end

      it "keeps a user_visit that only partly overlaps the range, with its real dates" do
        user_visit_on(visit, from: Date.new(2026, 4, 20), to: Date.new(2026, 4, 28))

        expect(user_rows).to contain_exactly(
          have_attributes(starts_on: Date.new(2026, 4, 20), ends_on: Date.new(2026, 4, 28)),
        )
      end

      it "leaves out a user_visit outside the range" do
        user_visit_on(visit, from: Date.new(2026, 9, 4), to: Date.new(2026, 9, 6))

        expect(user_rows).to eq []
      end

      it "leaves out a user_visit at another reserve" do
        elsewhere = create(:visit, reserve: create(:reserve), status: :approved,
          starts_at: Date.new(2026, 5, 1).in_time_zone,
          ends_at: Date.new(2026, 5, 12).in_time_zone.end_of_day)
        user_visit_on(elsewhere, from: Date.new(2026, 5, 4), to: Date.new(2026, 5, 6))

        expect(user_rows).to eq []
      end
    end

    context "with amenity_visits" do
      let(:visit) do
        create(:visit, reserve: reserve, status: :approved,
          starts_at: Date.new(2026, 5, 1).in_time_zone,
          ends_at: Date.new(2026, 5, 12).in_time_zone.end_of_day)
      end
      let(:bunkhouse) { create(:amenity, reserve: reserve, title: "Bunkhouse") }

      def amenity_visit_on(visit, from:, to:, status: :approved, **attributes)
        create(:amenity_visit, visit: visit, user: user, amenity: bunkhouse, status: status,
          arrives: from.in_time_zone, departs: to.in_time_zone.end_of_day, **attributes)
      end

      def amenity_rows
        schedule(reserve: reserve).entries.select(&:amenity?)
      end

      it "builds one row per amenity_visit, dated by its own arrival and departure" do
        first = amenity_visit_on(visit, from: Date.new(2026, 5, 2), to: Date.new(2026, 5, 3))
        second = amenity_visit_on(visit, from: Date.new(2026, 5, 4), to: Date.new(2026, 5, 6))

        expect(amenity_rows).to contain_exactly(
          have_attributes(id: first.id, visit_id: visit.id,
            starts_on: Date.new(2026, 5, 2), ends_on: Date.new(2026, 5, 3)),
          have_attributes(id: second.id, visit_id: visit.id,
            starts_on: Date.new(2026, 5, 4), ends_on: Date.new(2026, 5, 6)),
        )
      end

      it "labels the row with the amenity and its headcount" do
        amenity_visit_on(visit, from: Date.new(2026, 5, 4), to: Date.new(2026, 5, 6),
          number_of_people: 2, invoice: nil)

        expect(amenity_rows.first.title).to eq "Bunkhouse (2)"
      end

      it "marks an invoiced booking in its label" do
        amenity_visit_on(visit, from: Date.new(2026, 5, 4), to: Date.new(2026, 5, 6),
          number_of_people: 2, invoice: create(:invoice))

        expect(amenity_rows.first.title).to eq "$-Bunkhouse (2)"
      end

      it "takes its status from the amenity_visit rather than the visit" do
        amenity_visit_on(visit, from: Date.new(2026, 5, 4), to: Date.new(2026, 5, 6), status: :denied)

        expect(amenity_rows.first.status).to eq :denied
      end

      it "is incomplete whenever its visit is incomplete" do
        visit.update!(status: :incomplete)
        amenity_visit_on(visit, from: Date.new(2026, 5, 4), to: Date.new(2026, 5, 6))

        expect(amenity_rows.first.status).to eq :incomplete
      end

      it "keeps an amenity_visit that only partly overlaps the range, with its real dates" do
        amenity_visit_on(visit, from: Date.new(2026, 4, 20), to: Date.new(2026, 4, 28))

        expect(amenity_rows).to contain_exactly(
          have_attributes(starts_on: Date.new(2026, 4, 20), ends_on: Date.new(2026, 4, 28)),
        )
      end

      it "leaves out an amenity_visit outside the range" do
        amenity_visit_on(visit, from: Date.new(2026, 9, 4), to: Date.new(2026, 9, 6))

        expect(amenity_rows).to eq []
      end

      it "leaves out an amenity_visit at another reserve" do
        elsewhere = create(:visit, reserve: create(:reserve), status: :approved,
          starts_at: Date.new(2026, 5, 1).in_time_zone,
          ends_at: Date.new(2026, 5, 12).in_time_zone.end_of_day)
        amenity_visit_on(elsewhere, from: Date.new(2026, 5, 4), to: Date.new(2026, 5, 6))

        expect(amenity_rows).to eq []
      end
    end
  end

  describe "#visitor_counts" do
    it "is empty when no reserve is in scope" do
      expect(schedule(reserve: nil).visitor_counts).to eq({})
    end

    it "reads 0 for any date, even with no reserve in scope" do
      expect(schedule(reserve: nil).visitor_counts[Date.new(2026, 5, 4)]).to eq 0
    end

    it "sums the headcount across every day visitor covers" do
      approved_visit(reserve: reserve, user: user, count: 3,
        from: Date.new(2026, 5, 4), to: Date.new(2026, 5, 6))

      counts = schedule(reserve: reserve).visitor_counts

      expect(counts[Date.new(2026, 5, 4)]).to eq 3
      expect(counts[Date.new(2026, 5, 6)]).to eq 3
      expect(counts[Date.new(2026, 5, 7)]).to eq 0
    end

    it "adds up overlapping visitors on the same day" do
      approved_visit(reserve: reserve, user: user, count: 2,
        from: Date.new(2026, 5, 4), to: Date.new(2026, 5, 5))
      approved_visit(reserve: reserve, user: create(:user, :confirmed), count: 4,
        from: Date.new(2026, 5, 5), to: Date.new(2026, 5, 6))

      expect(schedule(reserve: reserve).visitor_counts[Date.new(2026, 5, 5)]).to eq 6
    end

    it "ignores amenity headcount" do
      visit = approved_visit(reserve: reserve, user: user, count: 2,
        from: Date.new(2026, 5, 4), to: Date.new(2026, 5, 5))
      create(:amenity_visit, visit: visit, user: user, status: :approved,
        number_of_people: 9,
        arrives: Date.new(2026, 5, 4).in_time_zone,
        departs: Date.new(2026, 5, 5).in_time_zone.end_of_day)

      expect(schedule(reserve: reserve).visitor_counts[Date.new(2026, 5, 4)]).to eq 2
    end

    it "excludes visit rows whose status is not selected" do
      approved_visit(reserve: reserve, user: user, count: 3,
        from: Date.new(2026, 5, 4), to: Date.new(2026, 5, 6))

      counts = schedule(reserve: reserve, statuses: [ :in_review, :incomplete ]).visitor_counts

      expect(counts[Date.new(2026, 5, 4)]).to eq 0
    end

    it "keeps the count when user rows are not asked for" do
      approved_visit(reserve: reserve, user: user, count: 3,
        from: Date.new(2026, 5, 4), to: Date.new(2026, 5, 6))

      counts = schedule(reserve: reserve, kinds: [ :visit, :amenity ]).visitor_counts

      expect(counts[Date.new(2026, 5, 4)]).to eq 3
    end

    it "counts only the days of a user_visit that fall inside the range" do
      approved_visit(reserve: reserve, user: user, count: 2,
        from: Date.new(2026, 4, 20), to: Date.new(2026, 4, 27))

      counts = schedule(reserve: reserve).visitor_counts

      expect(counts.keys).to contain_exactly(Date.new(2026, 4, 26), Date.new(2026, 4, 27))
    end

    it "counts a user_visit as incomplete when its visit is incomplete" do
      visit = approved_visit(reserve: reserve, user: user, count: 2,
        from: Date.new(2026, 5, 4), to: Date.new(2026, 5, 5))
      visit.update!(status: :incomplete)

      expect(schedule(reserve: reserve, statuses: [ :approved ]).visitor_counts[Date.new(2026, 5, 4)]).to eq 0
      expect(schedule(reserve: reserve, statuses: [ :incomplete ]).visitor_counts[Date.new(2026, 5, 4)]).to eq 2
    end

    it "leaves out user_visits at another reserve" do
      approved_visit(reserve: create(:reserve), user: user, count: 2,
        from: Date.new(2026, 5, 4), to: Date.new(2026, 5, 5))

      expect(schedule(reserve: reserve).visitor_counts[Date.new(2026, 5, 4)]).to eq 0
    end
  end
end
