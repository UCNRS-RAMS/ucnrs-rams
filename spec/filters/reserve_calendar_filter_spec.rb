require "rails_helper"

RSpec.describe ReserveCalendarFilter do
  def params_with(**overrides)
    described_class::DEFAULTS.merge(overrides).transform_values(&:to_s)
  end

  describe ".from_params" do
    context "when no toggle has been submitted" do
      it "falls back to the first-load defaults" do
        filter = described_class.from_params({})

        expect(filter.statuses).to eq [ :approved, :in_review, :incomplete ]
        expect(filter.kinds).to eq [ :visit, :amenity ]
        expect(filter.group_filter).to be_nil
      end
    end

    context "when the toggles have been submitted" do
      it "reads each one from its own param" do
        filter = described_class.from_params(params_with(show_approved: false, show_denied: true))

        expect(filter.show_approved?).to be false
        expect(filter.show_denied?).to be true
        expect(filter.show_in_review?).to be true
      end

      it "treats anything other than \"true\" as off" do
        filter = described_class.from_params(params_with(show_visits: "yes"))

        expect(filter.show_visits?).to be false
      end
    end
  end

  describe "#month and #year" do
    it "returns the submitted month and year" do
      filter = described_class.from_params({ month: "5", year: "2026" })

      expect([ filter.month, filter.year ]).to eq [ 5, 2026 ]
    end

    it "returns the current month and year when none is submitted" do
      travel_to Time.zone.local(2026, 10, 10) do
        filter = described_class.from_params({})

        expect([ filter.month, filter.year ]).to eq [ 10, 2026 ]
      end
    end

    it "returns the current month and year when the month is out of range" do
      travel_to Time.zone.local(2026, 10, 10) do
        filter = described_class.from_params({ month: "13", year: "2020" })

        expect([ filter.month, filter.year ]).to eq [ 10, 2026 ]
      end
    end
  end

  describe "#statuses" do
    it "returns the calendar status for each status toggle that is on" do
      filter = described_class.from_params(
        params_with(show_approved: false, show_cancelled: true, show_denied: true),
      )

      expect(filter.statuses).to eq [ :in_review, :incomplete, :cancelled, :denied ]
    end

    it "returns an empty array when every status toggle is off" do
      filter = described_class.from_params(
        params_with(show_approved: false, show_in_review: false, show_incomplete: false,
          show_cancelled: false, show_denied: false),
      )

      expect(filter.statuses).to eq []
    end
  end

  describe "#kinds" do
    it "returns the entry kind for each kind toggle that is on" do
      filter = described_class.from_params(
        params_with(show_visits: false, show_others: true, show_amenity: false),
      )

      expect(filter.kinds).to eq [ :user ]
    end
  end

  describe "#group?" do
    it "returns whether that group's toggle is on" do
      filter = described_class.from_params(params_with(group2: false))

      expect(filter.group?(1)).to be true
      expect(filter.group?(2)).to be false
    end
  end

  describe "#group_filter" do
    it "returns the selected group numbers as strings" do
      filter = described_class.from_params(params_with(group2: false, group4: false))

      expect(filter.group_filter).to eq [ "1", "3", "5" ]
    end

    it "returns nil when every group is selected" do
      filter = described_class.from_params(params_with)

      expect(filter.group_filter).to be_nil
    end

    it "returns nil when no group is selected" do
      filter = described_class.from_params(
        params_with(group1: false, group2: false, group3: false, group4: false, group5: false),
      )

      expect(filter.group_filter).to be_nil
    end
  end
end
