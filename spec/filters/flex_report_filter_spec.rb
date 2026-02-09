require "rails_helper"

RSpec.describe FlexReportFilter do
  describe "#flex_report_type_filter" do
    context "when :flex_report_type is provided" do
      it "returns the value" do
        filter = { flex_report_type: "a_r_part_1" }
        flex_filter = described_class.new(filter, nil)

        expect(flex_filter.flex_report_type_filter).to eq "a_r_part_1"
      end
    end

    context "when :flex_report_type is blank" do
      it "returns nil" do
        filter = { flex_report_type: "" }
        flex_filter = described_class.new(filter, nil)

        expect(flex_filter.flex_report_type_filter).to be_nil
      end
    end
  end

  describe "#reserve_filter" do
    context "when the filter contains a reserve" do
      it "uses the filter value" do
        filter = { reserve: "123" }
        flex_filter = described_class.new(filter, nil)

        expect(flex_filter.reserve_filter).to eq "123"
      end
    end

    context "when the filter omits the reserve" do
      it "returns the provided reserve id" do
        reserve = create(:reserve)
        flex_filter = described_class.new({}, reserve)

        expect(flex_filter.reserve_filter).to eq reserve.id
      end
    end
  end

  describe "#date_begin_filter" do
    it "returns the provided value" do
      filter = { date_begin: "2025-01-01" }
      flex_filter = described_class.new(filter, nil)

      expect(flex_filter.date_begin_filter).to eq "2025-01-01"
    end
  end

  describe "#date_end_filter" do
    it "returns the provided value" do
      filter = { date_end: "2025-01-31" }
      flex_filter = described_class.new(filter, nil)

      expect(flex_filter.date_end_filter).to eq "2025-01-31"
    end
  end

  describe "#present?" do
    context "when a filter hash is given" do
      it "returns true" do
        flex_filter = described_class.new({ flex_report_type: "a_r_part_1" }, nil)

        expect(flex_filter.present?).to be true
      end
    end

    context "when the filter is nil" do
      it "returns false" do
        flex_filter = described_class.new(nil, nil)

        expect(flex_filter.present?).to be false
      end
    end
  end
end
