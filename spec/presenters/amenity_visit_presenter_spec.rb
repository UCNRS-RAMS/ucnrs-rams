require "rails_helper"

RSpec.describe AmenityVisitPresenter do
  describe "delegations" do
    subject { AmenityVisitPresenter.new(create(:amenity_visit)) }
    it { is_expected.to delegate_method(:title).to(:amenity).with_prefix(true) }
    it { is_expected.to delegate_method(:per_sentence).to(:amenity) }
    it { is_expected.to delegate_method(:unit).to(:amenity) }
    it { is_expected.to delegate_method(:period).to(:amenity) }
    it { is_expected.to delegate_missing_methods_to(:amenity_visit) }
  end

  describe "#requested_date_range" do
    it "generates a date range" do
      arrives = Time.current.round
      departs = Time.current.round + 1.day
      presenter = AmenityVisitPresenter.new(
        create(:amenity_visit, arrives: arrives, departs: departs),
      )
      allow(DateRangePresenter).to receive(:value)

      presenter.requested_date_range

      expect(DateRangePresenter).to have_received(:value)
        .with(start_date: arrives, end_date: departs, format: nil)
    end
  end

  describe "#total_days" do
    it "return total days of amenity_visit" do
      arrives = Time.current
      departs = arrives + 1.day
      presenter = AmenityVisitPresenter.new(
        create(:amenity_visit, arrives: arrives, departs: departs),
      )
      output = ((departs.to_date + 1.day) - arrives.to_date).to_i
      
      expect(presenter.total_days).to eq output
    end
  end
  
  describe "#requested_date_time_range" do
    it "generates a date time range" do
      arrives = Time.current.round
      departs = Time.current.round + 1.day
      presenter = AmenityVisitPresenter.new(
        create(:amenity_visit, arrives: arrives, departs: departs),
      )
      allow(DateTimeRangePresenter).to receive(:value)

      presenter.requested_date_time_range

      expect(DateTimeRangePresenter).to have_received(:value)
        .with(start_datetime: arrives, end_datetime: departs, format: nil)
    end
  end

  describe "#rate_in_dollar" do
    it "converts rate into a string with 2 decimal places and $ sign at the beginning" do
      presenter = AmenityVisitPresenter.new(
        create(:amenity_visit, rate: 23.501)
      )

      expect(presenter.rate_in_dollar).to eq "$23.50"
    end
  end

  describe "#cost_in_dollar" do
    it "converts subtotal into a string with 2 decimal places and $ sign at the beginning" do
      presenter = AmenityVisitPresenter.new(
        create(:amenity_visit, number_of_people: 10, manual_units_of_time: 10, rate: 10)
      )

      expect(presenter.cost_in_dollar).to eq "$1000.00"
    end
  end

  describe "#arrives_today?" do
    context "when arrives datetime is within 24 hours of today" do
      it "returns true" do
        presenter = AmenityVisitPresenter.new(
          create(:amenity_visit, arrives: Time.current)
        )

        expect(presenter.arrives_today?).to eq true
      end
    end

    context "when arrives datetime is NOT within 24 hours of today" do
      it "returns false" do
        presenter = AmenityVisitPresenter.new(
          create(:amenity_visit, arrives: 1.day.from_now)
        )

        expect(presenter.arrives_today?).to eq false
      end
    end
  end

  describe "#departs_today?" do
    context "when departs datetime is within 24 hours of today" do
      it "returns true" do
        presenter = AmenityVisitPresenter.new(
          create(:amenity_visit, departs: Time.current)
        )

        expect(presenter.departs_today?).to eq true
      end
    end

    context "when departs datetime is NOT within 24 hours of today" do
      it "returns false" do
        presenter = AmenityVisitPresenter.new(
          create(:amenity_visit, departs: 1.day.from_now)
        )

        expect(presenter.departs_today?).to eq false
      end
    end
  end

  describe "#to_model" do
    it "returns self" do
      presenter = AmenityVisitPresenter.new(
        create(:amenity_visit)
      )

      expect(presenter.to_model).to eq presenter
    end
  end

  describe "#status_class" do
    it "returns 'invoiced amenity-status' css classes if amenity_visit status id 'INVOICED'" do
      presenter = AmenityVisitPresenter.new(
        create(:amenity_visit)
      )

      expect(presenter.status_class).to eq "invoiced amenity-status"
    end

    it "returns 'amenity-status' css classes if amenity_visit status id 'NEVER INVOICED'" do
      presenter = AmenityVisitPresenter.new(
        create(:amenity_visit, invoice_id: nil, invoice_now: false)
      )

      expect(presenter.status_class).to eq "amenity-status"
    end
  end

  describe "#disable" do
    it "returns 'disable' if amenity_visit status is 'INVOICED'" do
      presenter = AmenityVisitPresenter.new(
        create(:amenity_visit)
      )

      expect(presenter.disable).to eq "disable"
    end

    it "returns nil if amenity_visit status is not 'INVOICED'" do
      presenter = AmenityVisitPresenter.new(
        create(:amenity_visit, invoice_id: nil)
      )

      expect(presenter.disable).to eq nil
    end
  end

  describe "#invoice_status" do
    it "returns 'INVOICED' if amenity_visit is invoiced and invoice_now is true" do
      presenter = AmenityVisitPresenter.new(
        create(:amenity_visit)
      )

      expect(presenter.invoice_status).to eq "INVOICED"
    end

    it "returns nil if amenity_visit is not invoiced and invoice_now is true" do
      presenter = AmenityVisitPresenter.new(
        create(:amenity_visit, invoice_id: nil)
      )
      expect(presenter.invoice_status).to eq nil
    end

    it "returns nil if amenity_visit is not invoiced and invoice_now is true" do
      presenter = AmenityVisitPresenter.new(
        create(:amenity_visit, invoice_id: nil, invoice_now: false)
      )

      expect(presenter.invoice_status).to eq "NEVER INVOICED"
    end
  end

  describe "#invoiced?" do
    it "returns true if amenity visit is invoiced" do
      presenter = AmenityVisitPresenter.new(
        create(:amenity_visit)
      )

      expect(presenter.invoiced?).to eq true
    end

    it "returns false if amenity visit is not invoiced" do
      presenter = AmenityVisitPresenter.new(
        create(:amenity_visit, invoice_id: nil)
      )

      expect(presenter.invoiced?).to eq false
    end
  end

  describe "#to_partial_path" do
    it "returns 'amenity_visit'" do
      presenter = AmenityVisitPresenter.new(
        create(:amenity_visit)
      )

      expect(presenter.to_partial_path).to eq 'amenity_visit'
    end
  end
end
